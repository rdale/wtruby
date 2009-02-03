/***************************************************************************
    marshall_types.h - Derived from the PerlWt sources, see AUTHORS 
                       for details
 ***************************************************************************/

/*
 *   Copyright 2008-2009 by Richard Dale <richard.j.dale@gmail.com>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef MARSHALL_TYPES_H
#define MARSHALL_TYPES_H

#include <smoke/smoke.h>

#include "marshall.h"
#include "wtruby.h"
#include "smokeruby.h"

Marshall::HandlerFn getMarshallFn(const SmokeType &type);

namespace Wt {
  namespace Ruby {

class WTRUBY_EXPORT MethodReturnValueBase : public Marshall 
{
public:
    MethodReturnValueBase(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack);
    const Smoke::Method &method();
    Smoke::StackItem &item();
    Smoke *smoke();
    SmokeType type();
    void next();
    bool cleanup();
    void unsupported();
    VALUE * var();
protected:
    Smoke *_smoke;
    Smoke::Index _method;
    Smoke::Stack _stack;
    SmokeType _st;
    VALUE *_retval;
    virtual const char *classname();
};


class WTRUBY_EXPORT VirtualMethodReturnValue : public MethodReturnValueBase {
public:
    VirtualMethodReturnValue(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE retval);
    Marshall::Action action();

private:
    VALUE _retval2;
};


class WTRUBY_EXPORT MethodReturnValue : public MethodReturnValueBase {
public:
    MethodReturnValue(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE * retval);
    Marshall::Action action();

private:
    const char *classname();
};

class WTRUBY_EXPORT MethodCallBase : public Marshall
{
public:
    MethodCallBase(Smoke *smoke, Smoke::Index meth);
    MethodCallBase(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack);
    Smoke *smoke();
    SmokeType type();
    Smoke::StackItem &item();
    const Smoke::Method &method();
    virtual int items() = 0;
    virtual void callMethod() = 0;    
    void next();
    void unsupported();

protected:
    Smoke *_smoke;
    Smoke::Index _method;
    Smoke::Stack _stack;
    int _cur;
    Smoke::Index *_args;
    bool _called;
    VALUE *_sp;
    virtual const char* classname();
};


class WTRUBY_EXPORT VirtualMethodCall : public MethodCallBase {
public:
    VirtualMethodCall(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, VALUE obj, VALUE *sp);
    ~VirtualMethodCall();
    Marshall::Action action();
    VALUE * var();
    int items();
    void callMethod();
    bool cleanup();
 
private:
    VALUE _obj;
};


class WTRUBY_EXPORT MethodCall : public MethodCallBase {
public:
    MethodCall(Smoke *smoke, Smoke::Index method, VALUE target, VALUE *sp, int items);
    ~MethodCall();
    Marshall::Action action();
    VALUE * var();

    inline void callMethod() {
        if(_called) return;
        _called = true;

        if (_target == Qnil && !(method().flags & Smoke::mf_static)) {
            rb_raise(rb_eArgError, "%s is not a class method\n", _smoke->methodNames[method().name]);
        }
    
        Smoke::ClassFn fn = _smoke->classes[method().classId].classFn;
        void * ptr = 0;

        if (_o != 0) {
            const Smoke::Class &cl = _smoke->classes[method().classId];

            ptr = _o->smoke->cast(    _o->ptr,
                                    _o->classId,
                                    _o->smoke->idClass(cl.className, true).index );
        }

        _items = -1;
        (*fn)(method().method, ptr, _stack);
        if (method().flags & Smoke::mf_ctor) {
            Smoke::StackItem s[2];
            s[1].s_voidp = modules[_smoke].binding;
            (*fn)(0, _stack[0].s_voidp, s);
        }
        MethodReturnValue r(_smoke, _method, _stack, &_retval);
    }

    int items();
    bool cleanup();
private:
    VALUE _target;
    smokeruby_object * _o;
    VALUE *_sp;
    int _items;
    VALUE _retval;
    const char *classname();
};

  }
}

#endif
