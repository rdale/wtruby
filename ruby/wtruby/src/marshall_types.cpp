/***************************************************************************
    marshall_types.cpp - Derived from the QtRuby sources, see AUTHORS
                         for details

                             -------------------
    begin                : Tue Aug 26 2008
    copyright            : (C) 2003-2008 by Richard Dale
    email                : richard.j.dale@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <string>

#include "marshall_types.h"
#include <smoke/wt_smoke.h>

static bool wtruby_embedded = false;

extern "C" {

WTRUBY_EXPORT void 
set_wtruby_embedded(bool yn) {
#if !defined(RUBY_INIT_STACK)
    if (yn) {
        printf("ERROR: set_wtruby_embedded(true) called but RUBY_INIT_STACK is undefined");
        printf("       Upgrade to Ruby 1.8.6 or greater");
    }
#endif
    wtruby_embedded = yn;
}

}

// This is based on the SWIG SWIG_INIT_STACK and SWIG_RELEASE_STACK macros.
// If RUBY_INIT_STACK is only called when an embedded extension such as, a
// Ruby Plasma plugin is loaded, then later the C++ stack can drop below where the 
// Ruby runtime thinks the stack should start (ie the stack position when the 
// plugin was loaded), and result in sys stackerror exceptions
//
// TODO: While constructing the main class of a plugin when it is being loaded, 
// there could be a problem when a custom virtual method is called or a slot is
// invoked, because RUBY_INIT_STACK will have aleady have been called from within 
// the krubypluginfactory code, and it shouldn't be called again.

#if defined(RUBY_INIT_STACK)
#  define WTRUBY_INIT_STACK                            \
      if ( wtruby_embedded && nested_callback_count == 0 ) { RUBY_INIT_STACK } \
      nested_callback_count++;
#  define WTRUBY_RELEASE_STACK nested_callback_count--;

static unsigned int nested_callback_count = 0;

#else  /* normal non-embedded extension */

#  define WTRUBY_INIT_STACK
#  define WTRUBY_RELEASE_STACK
#endif  /* RUBY_EMBEDDED */

//
// This function was borrowed from the kross code. It puts out
// an error message and stacktrace on stderr for the current exception.
//
static void
show_exception_message()
{
    VALUE info = rb_gv_get("$!");
    VALUE bt = rb_funcall(info, rb_intern("backtrace"), 0);
    VALUE message = RARRAY_PTR(bt)[0];

    std::string errormessage =  std::string(STR2CSTR(message)) + ": "
                                + STR2CSTR(rb_obj_as_string(info))
                                + "(" + rb_class2name(CLASS_OF(info)) + ")";
    fprintf(stderr, "%s\n", errormessage.c_str());

    std::string tracemessage;
    for (int i = 1; i < RARRAY_LEN(bt); ++i) {
        if (TYPE(RARRAY_PTR(bt)[i]) == T_STRING) {
            std::string s = std::string(STR2CSTR(RARRAY_PTR(bt)[i])) + "\n";
            tracemessage += s;
            fprintf(stderr, "\t%s", s.c_str());
        }
    }
}

static VALUE funcall2_protect_id = Qnil;
static int funcall2_protect_argc = 0;
static VALUE * funcall2_protect_args = 0;

static VALUE
funcall2_protect(VALUE obj)
{
    VALUE result = Qnil;
    result = rb_funcall2(obj, funcall2_protect_id, funcall2_protect_argc, funcall2_protect_args);
    return result;
}

#  define WTRUBY_FUNCALL2(result, obj, id, argc, args) \
      if (wtruby_embedded) { \
          int state = 0; \
          funcall2_protect_id = id; \
          funcall2_protect_argc = argc; \
          funcall2_protect_args = args; \
          result = rb_protect(funcall2_protect, obj, &state); \
          if (state != 0) { \
              show_exception_message(); \
              result = Qnil; \
          } \
      } else { \
          result = rb_funcall2(obj, id, argc, args); \
      }


namespace Wt {
  namespace Ruby {

MethodReturnValueBase::MethodReturnValueBase(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack) :
    _smoke(smoke), _method(meth), _stack(stack) 
{ 
    _st.set(_smoke, method().ret);
}

const Smoke::Method&
MethodReturnValueBase::method() 
{ 
    return _smoke->methods[_method]; 
}

Smoke::StackItem&
MethodReturnValueBase::item() 
{ 
    return _stack[0]; 
}

Smoke *
MethodReturnValueBase::smoke() 
{ 
    return _smoke; 
}

SmokeType 
MethodReturnValueBase::type() 
{ 
    return _st; 
}

void 
MethodReturnValueBase::next() {}

bool 
MethodReturnValueBase::cleanup() 
{ 
    return false; 
}

void 
MethodReturnValueBase::unsupported() 
{
    rb_raise(rb_eArgError, "Cannot handle '%s' as return-type of %s::%s",
    type().name(),
    classname(),
    _smoke->methodNames[method().name]);    
}

VALUE * 
MethodReturnValueBase::var() 
{ 
    return _retval; 
}

const char *
MethodReturnValueBase::classname() 
{ 
    return _smoke->className(method().classId); 
}


VirtualMethodReturnValue::VirtualMethodReturnValue(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE retval) :
    MethodReturnValueBase(smoke, meth, stack), _retval2(retval) 
{
    _retval = &_retval2;
    Marshall::HandlerFn fn = getMarshallFn(type());
    (*fn)(this);
}

Marshall::Action 
VirtualMethodReturnValue::action() 
{ 
    return Marshall::FromVALUE; 
}

MethodReturnValue::MethodReturnValue(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE * retval) :
    MethodReturnValueBase(smoke, meth, stack) 
{
    _retval = retval;
    Marshall::HandlerFn fn = getMarshallFn(type());
    (*fn)(this);
}

Marshall::Action 
MethodReturnValue::action() 
{ 
    return Marshall::ToVALUE; 
}

const char *
MethodReturnValue::classname() 
{ 
    return strcmp(MethodReturnValueBase::classname(), "QGlobalSpace") == 0 ? "" : MethodReturnValueBase::classname(); 
}


MethodCallBase::MethodCallBase(Smoke *smoke, Smoke::Index meth) :
    _smoke(smoke), _method(meth), _cur(-1), _called(false), _sp(0)  
{  
}

MethodCallBase::MethodCallBase(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack) :
    _smoke(smoke), _method(meth), _stack(stack), _cur(-1), _called(false), _sp(0) 
{  
}

Smoke *
MethodCallBase::smoke() 
{ 
    return _smoke; 
}

SmokeType 
MethodCallBase::type() 
{ 
    return SmokeType(_smoke, _args[_cur]); 
}

Smoke::StackItem &
MethodCallBase::item() 
{ 
    return _stack[_cur + 1]; 
}

const Smoke::Method &
MethodCallBase::method() 
{ 
    return _smoke->methods[_method]; 
}
    
void 
MethodCallBase::next() 
{
    int oldcur = _cur;
    _cur++;
    while(!_called && _cur < items() ) {
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
        _cur++;
    }

    callMethod();
    _cur = oldcur;
}

void 
MethodCallBase::unsupported() 
{
    rb_raise(rb_eArgError, "Cannot handle '%s' as argument of %s::%s",
        type().name(),
        classname(),
        _smoke->methodNames[method().name]);
}

const char* 
MethodCallBase::classname() 
{ 
    return _smoke->className(method().classId); 
}


VirtualMethodCall::VirtualMethodCall(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE obj, VALUE *sp) :
    MethodCallBase(smoke,meth,stack), _obj(obj)
{        
    _sp = sp;
    _args = _smoke->argumentList + method().args;
}

VirtualMethodCall::~VirtualMethodCall() 
{
}

Marshall::Action 
VirtualMethodCall::action() 
{ 
    return Marshall::ToVALUE; 
}

VALUE *
VirtualMethodCall::var() 
{ 
    return _sp + _cur; 
}
    
int 
VirtualMethodCall::items() 
{ 
    return method().numArgs; 
}

void 
VirtualMethodCall::callMethod() 
{
    if (_called) return;
    _called = true;

    VALUE _retval;
    WTRUBY_INIT_STACK
    WTRUBY_FUNCALL2(_retval, _obj, rb_intern(_smoke->methodNames[method().name]), method().numArgs, _sp)
    WTRUBY_RELEASE_STACK

    VirtualMethodReturnValue r(_smoke, _method, _stack, _retval);
}

bool 
VirtualMethodCall::cleanup() 
{ 
    return false; 
}

MethodCall::MethodCall(Smoke *smoke, Smoke::Index method, VALUE target, VALUE *sp, int items) :
    MethodCallBase(smoke,method), _target(target), _o(0), _sp(sp), _items(items)
{
    if (_target != Qnil) {
        smokeruby_object *o = value_obj_info(_target);
        if (o != 0 && o->ptr != 0) {
            _o = o;
        }
    }

    _args = _smoke->argumentList + _smoke->methods[_method].args;
    _items = _smoke->methods[_method].numArgs;
    _stack = new Smoke::StackItem[items + 1];
    _retval = Qnil;
}

MethodCall::~MethodCall() 
{
    delete[] _stack;
}

Marshall::Action 
MethodCall::action() 
{ 
    return Marshall::FromVALUE; 
}

VALUE * 
MethodCall::var() 
{
    if (_cur < 0) return &_retval;
    return _sp + _cur;
}

int 
MethodCall::items() 
{ 
    return _items; 
}

bool 
MethodCall::cleanup() 
{ 
    return true; 
}

const char *
MethodCall::classname() 
{ 
    return strcmp(MethodCallBase::classname(), "QGlobalSpace") == 0 ? "" : MethodCallBase::classname(); 
}

  }
}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;

