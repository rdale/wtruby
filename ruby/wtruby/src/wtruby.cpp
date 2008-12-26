/***************************************************************************
                          wtruby.cpp  -  description
                             -------------------
    begin                : Tue Aug 26 2008
    copyright            : (C) 2008 by Richard Dale
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

#include <boost/regex.hpp>

#include <Wt/WDate>
#include <Wt/WServer>
#include <Wt/WEnvironment>
#include <Wt/WEvent>
#include <Wt/WApplication>
#include <Wt/WModelIndex>
#include <Wt/WAbstractItemModel>

#include <smoke/smoke.h>
#include <smoke/wt_smoke.h>
#include <ruby.h>

#include "marshall_types.h"
#include "wtruby.h"

extern TypeHandler Wt_handlers[];
extern const char * resolve_classname_wt(smokeruby_object * o);

Smoke::ModuleIndex _current_method = { 0, 0 };

extern void define_eventsignals(VALUE klass);
extern void define_signals(VALUE klass);

namespace Wt {
  namespace Ruby {
    typedef std::map<std::string, Smoke::ModuleIndex *> MethodCache;
    MethodCache methcache;

    static VALUE ruby_stateless_slot_class;
  }
}

extern "C" {

//---------- Ruby methods (for all functions except fully qualified statics & enums) ---------

static const char *
value_to_type_flag(VALUE ruby_value)
{
    const char * classname = rb_obj_classname(ruby_value);
    const char *r = "";
    if (ruby_value == Qnil) {
        r = "u";
    } else if ( TYPE(ruby_value) == T_FIXNUM 
                || TYPE(ruby_value) == T_BIGNUM 
                || std::strcmp(classname, "Wt::Integer" ) == 0 ) 
    {
        r = "i";
    } else if (TYPE(ruby_value) == T_FLOAT) {
        r = "n";
    } else if (TYPE(ruby_value) == T_STRING) {
        r = "s";
    } else if ( ruby_value == Qtrue 
                || ruby_value == Qfalse 
                || std::strcmp(classname, "Wt::Boolean") == 0 )
    {
        r = "B";
    } else if (std::strcmp(classname, "Wt::Enum") == 0) {
        VALUE temp = rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_wenum_type"), 1, ruby_value);
        r = StringValuePtr(temp);
    } else if (TYPE(ruby_value) == T_DATA) {
        smokeruby_object *o = value_obj_info(ruby_value);
        if (o == 0 || o->smoke == 0) {
            r = "a";
        } else {
            r = o->smoke->classes[o->classId].className;
        }
    } else {
        r = "U";
    }

    return r;
}

static std::string *
find_cached_selector(int argc, VALUE * argv, VALUE klass, const char * methodName)
{
    // Look in the cache
static std::string * mcid = 0;
    if (mcid == 0) {
        mcid = new std::string;
    }

    *mcid = rb_class2name(klass);
    *mcid += ';';
    *mcid += methodName;
    for (int i = 4; i < argc ; i++) {
        *mcid += ';';
        *mcid += value_to_type_flag(argv[i]);
    }
    Smoke::ModuleIndex *rcid = Wt::Ruby::methcache[*mcid];
#ifdef DEBUG
    if (Wt::Ruby::do_debug & wtdb_calls) printf("method_missing mcid: %s\n", (const char *) *mcid);
#endif
    
    if (rcid != 0) {
        // Got a hit
#ifdef DEBUG
        if (Wt::Ruby::do_debug & wtdb_calls) {
            printf("method_missing cache hit, mcid: %s\n", (const char *) *mcid);
        }
#endif
        _current_method.smoke = rcid->smoke;
        _current_method.index = rcid->index;
    } else {
        _current_method.smoke = 0;
        _current_method.index = -1;
    }
    
    return mcid;
}

VALUE
method_missing(int argc, VALUE * argv, VALUE self)
{
    const char * methodName = rb_id2name(SYM2ID(argv[0]));
    VALUE klass = rb_funcall(self, rb_intern("class"), 0);

    VALUE retval = Qnil;

    // Look for 'thing?' methods, and try to match isThing() or hasThing() in the Smoke runtime
    std::string pred(methodName);
    
    if (pred[pred.size() - 1] == '?') {
        smokeruby_object *o = value_obj_info(self);
        if (o == 0 || o->ptr == 0) {
            return rb_call_super(argc, argv);
        }
        
        // Drop the trailing '?'
        pred.resize(pred.length() - 1);
        pred[0] = std::toupper(pred[0]);
        pred.replace(0, 0, "is");
        Smoke::ModuleIndex meth = o->smoke->findMethod(o->smoke->classes[o->classId].className, pred.c_str());
        
        if (meth.index == 0) {
            pred.replace(0, 2, "has");
            meth = o->smoke->findMethod(o->smoke->classes[o->classId].className, pred.c_str());
        }
        
        if (meth.index > 0) {
            methodName = (char *) pred.c_str();
        }
    }
        
    VALUE * temp_stack = ALLOCA_N(VALUE, argc+3);
    temp_stack[0] = rb_str_new2("Wt");
    temp_stack[1] = rb_str_new2(methodName);
    temp_stack[2] = klass;
    temp_stack[3] = self;
    for (int count = 1; count < argc; count++) {
        temp_stack[count+3] = argv[count];
    }

    {
        std::string * mcid = find_cached_selector(argc+3, temp_stack, klass, methodName);

        if (_current_method.index == -1) {
            // Find the C++ method to call. Do that from Ruby for now

            retval = rb_funcall2(Wt::Ruby::wt_internal_module, rb_intern("do_method_missing"), argc+3, temp_stack);
            if (_current_method.index == -1) {
                const char * op = rb_id2name(SYM2ID(argv[0]));
                if (    std::strcmp(op, "-") == 0
                        || std::strcmp(op, "+") == 0
                        || std::strcmp(op, "/") == 0
                        || std::strcmp(op, "%") == 0
                        || std::strcmp(op, "|") == 0 )
                {
                    // Look for operator methods of the form 'operator+=', 'operator-=' and so on..
                    char op1[3];
                    op1[0] = op[0];
                    op1[1] = '=';
                    op1[2] = '\0';
                    temp_stack[1] = rb_str_new2(op1);
                    retval = rb_funcall2(Wt::Ruby::wt_internal_module, rb_intern("do_method_missing"), argc+3, temp_stack);
                }

                if (_current_method.index == -1) { 
                    return rb_call_super(argc, argv);
                }
            }
            // Success. Cache result.
            Wt::Ruby::methcache[*mcid] = new Smoke::ModuleIndex(_current_method);
        }
    }
    Wt::Ruby::MethodCall c(_current_method.smoke, _current_method.index, self, temp_stack+4, argc-1);
    c.next();
    VALUE result = *(c.var());
    return result;
}

VALUE
class_method_missing(int argc, VALUE * argv, VALUE klass)
{
    VALUE result = Qnil;
    VALUE retval = Qnil;
    const char * methodName = rb_id2name(SYM2ID(argv[0]));
    VALUE * temp_stack = ALLOCA_N(VALUE, argc+3);
    temp_stack[0] = rb_str_new2("Wt");
    temp_stack[1] = rb_str_new2(methodName);
    temp_stack[2] = klass;
    temp_stack[3] = Qnil;
    for (int count = 1; count < argc; count++) {
        temp_stack[count+3] = argv[count];
    }

    {
        std::string * mcid = find_cached_selector(argc+3, temp_stack, klass, methodName);

        if (_current_method.index == -1) {
            retval = rb_funcall2(Wt::Ruby::wt_internal_module, rb_intern("do_method_missing"), argc+3, temp_stack);
            if (_current_method.index != -1) {
                // Success. Cache result.
                Wt::Ruby::methcache[*mcid] = new Smoke::ModuleIndex(_current_method);
            }
        }
    }

    if (_current_method.index == -1) {
        boost::regex rx("[a-zA-Z]+");
        
        if (!boost::regex_match(methodName, rx)) {
            // If an operator method hasn't been found as an instance method,
            // then look for a class method - after 'op(self,a)' try 'self.op(a)' 
            VALUE * method_stack = ALLOCA_N(VALUE, argc - 1);
            method_stack[0] = argv[0];
            for (int count = 1; count < argc - 1; count++) {
                method_stack[count] = argv[count+1];
            }
            result = method_missing(argc-1, method_stack, argv[1]);
            return result;
        } else {
            return rb_call_super(argc, argv);
        }
    }

    Wt::Ruby::MethodCall c(_current_method.smoke, _current_method.index, Qnil, temp_stack+4, argc-1);
    c.next();
    result = *(c.var());
    return result;
}

static VALUE module_method_missing(int argc, VALUE * argv, VALUE klass)
{
    return class_method_missing(argc, argv, klass);
}

/*

class LCDRange < Wt::WWidget

    def initialize(s, parent, name)
        super(parent, name)
        init()
        ...

For a case such as the above, the Wt::WWidget can't be instantiated until
the initializer has been run up to the point where 'super(parent, name)'
is called. Only then, can the number and type of arguments passed to the
constructor be known. However, the rest of the intializer
can't be run until 'self' is a proper T_DATA object with a wrapped C++
instance.

The solution is to run the initialize code twice. First, only up to the
'super(parent, name)' call, where the Wt::WWidget would get instantiated
in initialize_wt(). And then rb_throw() jumps out of the
initializer returning the wrapped object as a result.

The second time round 'self' will be the wrapped instance of type T_DATA,
so initialize() can be allowed to proceed to the end.
*/
static VALUE
initialize_wt(int argc, VALUE * argv, VALUE self)
{
    VALUE retval = Qnil;
    VALUE temp_obj;
    
    if (TYPE(self) == T_DATA) {
        // If a ruby block was passed to the constructor then run that now
        if (rb_block_given_p()) {
            rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("run_initializer_block"), 2, self, rb_block_proc());
        }

        return self;
    }

    VALUE klass = rb_funcall(self, rb_intern("class"), 0);
    VALUE constructor_name = rb_str_new2("new");

    VALUE * temp_stack = ALLOCA_N(VALUE, argc+4);

    temp_stack[0] = rb_str_new2("Wt");
    temp_stack[1] = constructor_name;
    temp_stack[2] = klass;
    temp_stack[3] = self;
    
    for (int count = 0; count < argc; count++) {
        temp_stack[count+4] = argv[count];
    }

    { 
        std::string * mcid = find_cached_selector(argc+4, temp_stack, klass, rb_class2name(klass));

        if (_current_method.index == -1) {
            retval = rb_funcall2(Wt::Ruby::wt_internal_module, rb_intern("do_method_missing"), argc+4, temp_stack);
            if (_current_method.index != -1) {
                // Success. Cache result.
                Wt::Ruby::methcache[*mcid] = new Smoke::ModuleIndex(_current_method);
            }
        }
    }

    if (_current_method.index == -1) {
        // Another longjmp here..
        rb_raise(rb_eArgError, "unresolved constructor call %s\n", rb_class2name(klass));
    }
    
    {
        // Allocate the MethodCall within a C block. Otherwise, because the continue_new_instance()
        // call below will longjmp out, it wouldn't give C++ an opportunity to clean up
        Wt::Ruby::MethodCall c(_current_method.smoke, _current_method.index, self, temp_stack+4, argc);
        c.next();
        temp_obj = *(c.var());
    }
    
    smokeruby_object * p = 0;
    Data_Get_Struct(temp_obj, smokeruby_object, p);

    smokeruby_object  * o = alloc_smokeruby_object( true, 
                                                    p->smoke, 
                                                    p->classId, 
                                                    p->ptr );
    p->ptr = 0;
    p->allocated = false;

    VALUE result = Data_Wrap_Struct(klass, smokeruby_mark, smokeruby_free, o);
    mapObject(result, result);
    // Off with a longjmp, never to return..
    rb_throw("new_wt", result);
    /*NOTREACHED*/
    return self;
}

static VALUE
new_wt(int argc, VALUE * argv, VALUE klass)
{
    VALUE * temp_stack = ALLOCA_N(VALUE, argc + 1);
    temp_stack[0] = rb_obj_alloc(klass);

    for (int count = 0; count < argc; count++) {
        temp_stack[count+1] = argv[count];
    }

    VALUE result = rb_funcall2(Wt::Ruby::wt_internal_module, rb_intern("try_initialize"), argc+1, temp_stack);
    rb_obj_call_init(result, argc, argv);
    
    return result;
}

// A block passed to Wt::WRun(), which is run by createApplication(), a function
// that is called by the Wt runtime every time a new user connects.
static VALUE applicationInitializer = Qnil;

static Wt::WApplication *
createApplication(const Wt::WEnvironment& env)
{
    smokeruby_object *  e = alloc_smokeruby_object( false, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::WEnvironment").index, 
                                                    (void *) &env );
    VALUE environment = set_obj_info("Wt::WEnvironment", e);
    VALUE result = rb_funcall(applicationInitializer, rb_intern("call"), 1, environment);
    smokeruby_object * r = value_obj_info(result);

    if (r == 0 || r->ptr == 0 || r->classId != wt_Smoke->idClass("Wt::WApplication").index) {
        rb_raise(rb_eRuntimeError, "Wt::WRun initialization block didn't return a Wt::WApplication");
        return 0;
    } else {
        return static_cast<Wt::WApplication*>(r->ptr);
    }
}

static VALUE
wt_wrun(VALUE klass, VALUE args)
{
    if (rb_block_given_p()) {
        applicationInitializer = rb_block_proc();
    }

    int argc = RARRAY(args)->len + 1;
    char ** argv = new char *[argc];

    VALUE program_name = rb_gv_get("$0");
    char * arg = StringValuePtr(program_name);
    argv[0] = new char[strlen(arg) + 1];
    strcpy(argv[0], arg);

    for (long i = 0; i < RARRAY(args)->len; i++) {
        VALUE item = rb_ary_entry(args, i);
        arg = StringValuePtr(item);
        argv[i + 1] = new char[strlen(arg) + 1];
        strcpy(argv[i + 1], arg);
    }

    Wt::WRun(argc, argv, &createApplication);
    return Qnil;
}

static VALUE
new_boost_any(int argc, VALUE * argv, VALUE klass)
{
    if (argc == 1) {
        boost::any * v = 0;

        if (TYPE(argv[0]) == T_STRING) {
            v = new boost::any(Wt::WString(StringValuePtr(argv[0])));
        } else if (TYPE(argv[0]) == T_FIXNUM) {
            v = new boost::any(NUM2INT(argv[0]));
        } else if (TYPE(argv[0]) == T_FLOAT) {
            v = new boost::any(NUM2DBL(argv[0]));
        } else if (TYPE(argv[0]) == T_DATA) {
            smokeruby_object * o = value_obj_info(argv[0]);
            if (o != 0 && o->ptr != 0) {
                if (std::strcmp(wt_Smoke->classes[o->classId].className, "Wt::WDate") == 0) {
                    v = new boost::any(*(static_cast<Wt::WDate *>(o->ptr)));
                }
            }
        }

        if (v == 0) {
            return rb_call_super(argc, argv);
        }

        smokeruby_object  * o = alloc_smokeruby_object( true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("boost::any").index, 
                                                        static_cast<void *>(v) );

        VALUE result = Data_Wrap_Struct(klass, smokeruby_mark, smokeruby_free, o);
        mapObject(result, result);
        return result;
    }

    return rb_call_super(argc, argv);
}

static VALUE
boost_any_value(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    boost::any * v = static_cast<boost::any*>(o->ptr);

    if (v->type() == typeid(int)) {
        return INT2NUM(boost::any_cast<int>(*v));
    } else if (v->type() == typeid(double)) {
        return rb_float_new(boost::any_cast<double>(*v));
    } else if (v->type() == typeid(std::string)) {
        return rb_str_new2(boost::any_cast<std::string>(*v).c_str());
    } else if (v->type() == typeid(Wt::WString)) {
        return rb_str_new2(boost::any_cast<Wt::WString&>(*v).toUTF8().c_str());
    } else if (v->type() == typeid(Wt::WDate)) {
        smokeruby_object * d = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WDate").index, 
                                                        new Wt::WDate(boost::any_cast<Wt::WDate>(*v)) );
        return set_obj_info("Wt::WDate", d);
    }

    return Qnil;
}

static VALUE
boost_any_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    boost::any * v = static_cast<boost::any *>(o->ptr);
    return rb_str_new2(v->type().name());
}

static VALUE
wt_std_ostream_write(VALUE self, VALUE data)
{
    std::ostream * s = 0;
    Data_Get_Struct(self, std::ostream, s);
    s->write(RSTRING_PTR(data), RSTRING_LEN(data));
    return self;
}

static VALUE
wt_std_ostream_flush(VALUE self)
{
    std::ostream * s = 0;
    Data_Get_Struct(self, std::ostream, s);
    s->flush();
    return self;
}

static VALUE
wabstractitemmodel_createindex(int argc, VALUE * argv, VALUE self)
{
    if (argc == 2 || argc == 3) {
        smokeruby_object * o = value_obj_info(self);
        Smoke::ModuleIndex nameId = o->smoke->idMethodName("createIndex$$$");
        Smoke::ModuleIndex meth = o->smoke->findMethod(wt_Smoke->findClass("Wt::WAbstractItemModel"), nameId);
        Smoke::Index i = meth.smoke->methodMaps[meth.index].method;
        i = -i;     // turn into ambiguousMethodList index
        while (o->smoke->ambiguousMethodList[i] != 0) {
            if (    strcmp( o->smoke->types[o->smoke->argumentList[o->smoke->methods[o->smoke->ambiguousMethodList[i]].args + 2]].name,
                            "void*" ) == 0 )
            {
                Smoke::Method &m = o->smoke->methods[o->smoke->ambiguousMethodList[i]];
                Smoke::ClassFn fn = o->smoke->classes[m.classId].classFn;
                Smoke::StackItem stack[4];
                stack[1].s_int = NUM2INT(argv[0]);
                stack[2].s_int = NUM2INT(argv[1]);
                if (argc == 2) {
                    stack[3].s_voidp = (void*) Qnil;
                } else {
                    stack[3].s_voidp = (void*) argv[2];
                }
                (*fn)(m.method, o->ptr, stack);
                smokeruby_object  * result = alloc_smokeruby_object(    true, 
                                                                        o->smoke, 
                                                                        o->smoke->idClass("Wt::WModelIndex").index, 
                                                                        stack[0].s_voidp );

                return set_obj_info("Wt::WModelIndex", result);
            }

            i++;
        }
    }

    return rb_call_super(argc, argv);
}

static VALUE
wmodelindex_internalpointer(VALUE self)
{
    smokeruby_object *o = value_obj_info(self);
    Wt::WModelIndex * index = static_cast<Wt::WModelIndex *>(o->ptr);
    void * ptr = index->internalPointer();
    return ptr != 0 ? (VALUE) ptr : Qnil;
}

static VALUE
wobject_implementstateless(int argc, VALUE * argv, VALUE self)
{
    VALUE stateless_slots = rb_funcall(self, rb_intern("stateless_slots"), 0);
    if (stateless_slots == Qnil) {
        stateless_slots = rb_hash_new();
        rb_funcall(self, rb_intern("stateless_slots="), 1, stateless_slots);
    }

    VALUE stateless_slot = Qnil;

    if (argc == 1 && TYPE(argv[0]) == T_SYMBOL) {
        stateless_slot = rb_funcall(Wt::Ruby::ruby_stateless_slot_class, rb_intern("new"), 2, self, argv[0]);
    } else if (argc == 2 && TYPE(argv[0]) == T_SYMBOL && TYPE(argv[1]) == T_SYMBOL) {
        stateless_slot = rb_funcall(Wt::Ruby::ruby_stateless_slot_class, rb_intern("new"), 3, self, argv[0], argv[1]);
    } else {
        return rb_call_super(argc, argv);
    }

    rb_hash_aset(stateless_slots, argv[0], stateless_slot);
    return self;
}

static VALUE
wobject_isstateless(VALUE self, VALUE method)
{
    VALUE statelessSlots = rb_funcall(self, rb_intern("stateless_slots"), 0);
    if (statelessSlots == Qnil) {
        return Qnil;
    }
    return rb_hash_aref(statelessSlots, method);
}

// --------------- Ruby C functions for Wt::_internal.* helpers  ----------------


static VALUE
getMethStat(VALUE /*self*/)
{
    VALUE result_list = rb_ary_new();
    rb_ary_push(result_list, INT2NUM((int) Wt::Ruby::methcache.size()));
    return result_list;
}

static VALUE
getClassStat(VALUE /*self*/)
{
    VALUE result_list = rb_ary_new();
    rb_ary_push(result_list, INT2NUM((int) Wt::Ruby::classcache.size()));
    return result_list;
}

static VALUE
getIsa(VALUE /*self*/, VALUE classId)
{
    VALUE parents_list = rb_ary_new();

    int id = NUM2INT(rb_funcall(classId, rb_intern("index"), 0));
    Smoke* smoke = Wt::Ruby::smokeList[NUM2INT(rb_funcall(classId, rb_intern("smoke"), 0))];

    Smoke::Index *parents = smoke->inheritanceList + smoke->classes[id].parents;

    while (*parents != 0) {
        //logger("\tparent: %s", wt_Smoke->classes[*parents].className);
        rb_ary_push(parents_list, rb_str_new2(smoke->classes[*parents++].className));
    }
    return parents_list;
}

static VALUE
class_name(VALUE self)
{
    VALUE klass = rb_funcall(self, rb_intern("class"), 0);
    return rb_funcall(klass, rb_intern("name"), 0);
}

static VALUE
setDebug(VALUE self, VALUE on_value)
{
    int on = NUM2INT(on_value);
    Wt::Ruby::do_debug = on;
    return self;
}

static VALUE
debugging(VALUE /*self*/)
{
    return INT2NUM(Wt::Ruby::do_debug);
}

static VALUE
get_arg_type_name(VALUE /*self*/, VALUE method_value, VALUE idx_value)
{
    int method = NUM2INT(rb_funcall(method_value, rb_intern("index"), 0));
    int smokeIndex = NUM2INT(rb_funcall(method_value, rb_intern("smoke"), 0));
    Smoke * smoke = Wt::Ruby::smokeList[smokeIndex];
    int idx = NUM2INT(idx_value);
    Smoke::Method &m = smoke->methods[method];
    Smoke::Index *args = smoke->argumentList + m.args;
    return rb_str_new2((char*)smoke->types[args[idx]].name);
}

static VALUE
classIsa(VALUE /*self*/, VALUE className_value, VALUE base_value)
{
    char *className = StringValuePtr(className_value);
    char *base = StringValuePtr(base_value);
    return wt_Smoke->isDerivedFromByName(className, base) ? Qtrue : Qfalse;
}

static VALUE
isEnum(VALUE /*self*/, VALUE enumName_value)
{
    char *enumName = StringValuePtr(enumName_value);
    Smoke::Index typeId = 0;
    Smoke* s = 0;
    for (unsigned int i = 0; i < Wt::Ruby::smokeList.size(); i++) {
         typeId = Wt::Ruby::smokeList[i]->idType(enumName);
         if (typeId > 0) {
             s = Wt::Ruby::smokeList[i];
             break;
         }
    }
    return  typeId > 0 
            && (    (s->types[typeId].flags & Smoke::tf_elem) == Smoke::t_enum
                    || (s->types[typeId].flags & Smoke::tf_elem) == Smoke::t_ulong
                    || (s->types[typeId].flags & Smoke::tf_elem) == Smoke::t_long
                    || (s->types[typeId].flags & Smoke::tf_elem) == Smoke::t_uint
                    || (s->types[typeId].flags & Smoke::tf_elem) == Smoke::t_int ) ? Qtrue : Qfalse;
}

static VALUE
insert_pclassid(VALUE self, VALUE p_value, VALUE mi_value)
{
    char *p = StringValuePtr(p_value);
    int ix = NUM2INT(rb_funcall(mi_value, rb_intern("index"), 0));
    int smokeidx = NUM2INT(rb_funcall(mi_value, rb_intern("smoke"), 0));
    Smoke::ModuleIndex mi = { Wt::Ruby::smokeList[smokeidx], ix };
    Wt::Ruby::classcache[std::string(p)] = new Smoke::ModuleIndex(mi);
    Wt::Ruby::IdToClassNameMap[mi] = new std::string(p);
    return self;
}

static VALUE
classid2name(VALUE /*self*/, VALUE mi_value)
{
    int ix = NUM2INT(rb_funcall(mi_value, rb_intern("index"), 0));
    int smokeidx = NUM2INT(rb_funcall(mi_value, rb_intern("smoke"), 0));
    Smoke::ModuleIndex mi = { Wt::Ruby::smokeList[smokeidx], ix };
    return rb_str_new2(Wt::Ruby::IdToClassNameMap[mi]->c_str());
}

static VALUE
find_pclassid(VALUE /*self*/, VALUE p_value)
{
    char *p = StringValuePtr(p_value);
    Smoke::ModuleIndex *r = Wt::Ruby::classcache[std::string(p)];
    if (r != 0) {
        return rb_funcall(  Wt::Ruby::moduleindex_class, 
                            rb_intern("new"), 
                            2, 
                            INT2NUM(Wt::Ruby::smokeListIndexOf(r->smoke)), 
                            INT2NUM(r->index) );
    } else {
        return rb_funcall(Wt::Ruby::moduleindex_class, rb_intern("new"), 2, 0, 0);
    }
}

static VALUE
get_value_type(VALUE /*self*/, VALUE ruby_value)
{
    return rb_str_new2(value_to_type_flag(ruby_value));
}


static VALUE
dispose(VALUE self)
{
    smokeruby_object *o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) { 
        return Qnil; 
    }

    const char *className = o->smoke->classes[o->classId].className;
    if (Wt::Ruby::do_debug & wtdb_gc) printf("Deleting (%s*)%p\n", className, o->ptr);
    
    unmapPointer(o, o->classId, 0);
    Wt::Ruby::object_count--;

    char *methodName = new char[strlen(className) + 2];
    methodName[0] = '~';
    strcpy(methodName + 1, className);
    Smoke::ModuleIndex nameId = o->smoke->findMethodName(className, methodName);
    Smoke::ModuleIndex classIdx = { o->smoke, o->classId };
    Smoke::ModuleIndex meth = nameId.smoke->findMethod(classIdx, nameId);
    if (meth.index > 0) {
        Smoke::Method &m = meth.smoke->methods[meth.smoke->methodMaps[meth.index].method];
        Smoke::ClassFn fn = meth.smoke->classes[m.classId].classFn;
        Smoke::StackItem i[1];
        (*fn)(m.method, o->ptr, i);
    }
    delete[] methodName;
    o->ptr = 0;
    o->allocated = false;
    
    return self;
}

static VALUE
is_disposed(VALUE self)
{
    smokeruby_object *o = value_obj_info(self);
    return (o != 0 && o->ptr != 0) ? Qfalse : Qtrue;
}

// Returns the Smoke classId of a ruby instance
static VALUE
idInstance(VALUE /*self*/, VALUE instance)
{
    smokeruby_object *o = value_obj_info(instance);
    if (o == 0) {
        return Qnil;
    }

    return rb_funcall(  Wt::Ruby::moduleindex_class, 
                        rb_intern("new"), 
                        2, 
                        INT2NUM(Wt::Ruby::smokeListIndexOf(o->smoke)), 
                        INT2NUM(o->classId) );
}

static VALUE
findClass(VALUE /*self*/, VALUE name_value)
{
    char *name = StringValuePtr(name_value);
    Smoke::ModuleIndex mi = wt_Smoke->findClass(name);
    return rb_funcall(  Wt::Ruby::moduleindex_class, 
                        rb_intern("new"), 
                        2, 
                        INT2NUM(Wt::Ruby::smokeListIndexOf(mi.smoke)), 
                        INT2NUM(mi.index) );
}

static VALUE
dumpCandidates(VALUE /*self*/, VALUE rmeths)
{
    VALUE errmsg = rb_str_new2("");
    if (rmeths != Qnil) {
        int count = RARRAY(rmeths)->len;
        for (int i = 0; i < count; i++) {
            rb_str_catf(errmsg, "\t");
            int id = NUM2INT(rb_funcall(rb_ary_entry(rmeths, i), rb_intern("index"), 0));
            Smoke* smoke = Wt::Ruby::smokeList[NUM2INT(rb_funcall(rb_ary_entry(rmeths, i), rb_intern("smoke"), 0))];
            Smoke::Method &meth = smoke->methods[id];
            const char *tname = smoke->types[meth.ret].name;
            if (meth.flags & Smoke::mf_enum) {
                rb_str_catf(errmsg, "enum ");
                rb_str_catf(errmsg, "%s::%s", smoke->classes[meth.classId].className, smoke->methodNames[meth.name]);
                rb_str_catf(errmsg, "\n");
            } else {
                if (meth.flags & Smoke::mf_static) {
                    rb_str_catf(errmsg, "static ");
                }
                rb_str_catf(errmsg, "%s ", (tname ? tname:"void"));
                rb_str_catf(errmsg, "%s::%s(", smoke->classes[meth.classId].className, smoke->methodNames[meth.name]);
                for (int i = 0; i < meth.numArgs; i++) {
                    if (i != 0) {
                        rb_str_catf(errmsg, ", ");
                    }
                    tname = smoke->types[smoke->argumentList[meth.args+i]].name;
                    rb_str_catf(errmsg, "%s", (tname ? tname:"void"));
                }
                rb_str_catf(errmsg, ")");
                if (meth.flags & Smoke::mf_const) {
                    rb_str_catf(errmsg, " const");
                }

                rb_str_catf(errmsg, "\n");
            }
        }
    }
    return errmsg;
}

static VALUE
isObject(VALUE /*self*/, VALUE obj)
{
    void * ptr = 0;
    ptr = value_to_ptr(obj);
    return (ptr > 0 ? Qtrue : Qfalse);
}

static VALUE
setCurrentMethod(VALUE self, VALUE meth_value)
{
    int smokeidx = NUM2INT(rb_funcall(meth_value, rb_intern("smoke"), 0));
    int meth = NUM2INT(rb_funcall(meth_value, rb_intern("index"), 0));
    // FIXME: damn, this is lame, and it doesn't handle ambiguous methods
    _current_method.smoke = Wt::Ruby::smokeList[smokeidx];  //wt_Smoke->methodMaps[meth].method;
    _current_method.index = meth;
    return self;
}

static VALUE
getClassList(VALUE /*self*/)
{
    VALUE class_list = rb_ary_new();

    for (int i = 1; i <= wt_Smoke->numClasses; i++) {
        if (wt_Smoke->classes[i].className) {
            rb_ary_push(class_list, rb_str_new2(wt_Smoke->classes[i].className));
        }
    }

    return class_list;
}

static VALUE
create_wt_class(VALUE /*self*/, VALUE package_value, VALUE module_value)
{
    const char * package = strdup(StringValuePtr(package_value));
    VALUE value_moduleName = rb_funcall(module_value, rb_intern("name"), 0);
    const char * moduleName = strdup(StringValuePtr(value_moduleName));
    VALUE klass = module_value;
    std::string packageName(package);

    unsigned int p1 = packageName.find("::", strlen(moduleName));
    unsigned int p2 = 0;
    while (p1 != std::string::npos) {
        p1 += strlen("::");
        p2 = packageName.find("::", p1);
        std::string s = packageName.substr(p1, p2 == std::string::npos ? packageName.size() : p2 - p1);
        klass = rb_define_class_under(klass, s.c_str(), Wt::Ruby::wt_base_class);

        p1 = p2;
    }

    for (   Wt::Ruby::Modules::iterator i = Wt::Ruby::modules.begin(); 
            i != Wt::Ruby::modules.end(); 
            ++i ) 
    {
        if (i->second.class_created != 0) {
            i->second.class_created(package, module_value, klass);
        }
    }

    if (std::strcmp(moduleName, "Wt::Ext") == 0) {
        rb_define_singleton_method(module_value, "method_missing", (VALUE (*) (...)) module_method_missing, -1);
        rb_define_singleton_method(module_value, "const_missing", (VALUE (*) (...)) module_method_missing, -1);
    }

    if (packageName == "Wt::EventSignalBase") {
        define_eventsignals(klass);
    } else if (packageName == "Wt::SignalBase") {
        define_signals(klass);
    } else if (packageName == "Boost::Any") {
        rb_define_singleton_method(klass, "new", (VALUE (*) (...)) new_boost_any, -1);
        rb_define_method(klass, "value", (VALUE (*) (...)) boost_any_value, 0);
        rb_define_method(klass, "name", (VALUE (*) (...)) boost_any_name, 0);
    } else if (packageName == "Wt::WAbstractItemModel") {
        rb_define_method(klass, "createIndex", (VALUE (*) (...)) wabstractitemmodel_createindex, -1);
        rb_define_method(klass, "create_index", (VALUE (*) (...)) wabstractitemmodel_createindex, -1);
    } else if (packageName == "Wt::WModelIndex") {
        rb_define_method(klass, "internalPointer", (VALUE (*) (...)) wmodelindex_internalpointer, 0);
        rb_define_method(klass, "internal_pointer", (VALUE (*) (...)) wmodelindex_internalpointer, 0);
    }

    if (wt_Smoke->isDerivedFromByName(package, "Wt::WObject")) {
        rb_define_method(klass, "implementStateless", (VALUE (*) (...)) wobject_implementstateless, -1);
        rb_define_method(klass, "implement_stateless", (VALUE (*) (...)) wobject_implementstateless, -1);
        rb_define_method(klass, "isStateless", (VALUE (*) (...)) wobject_isstateless, 1);
        rb_define_attr(klass, "stateless_slots", 1, 1);

    }

    free((void *) package);
    return klass;
}

static VALUE
wtruby_version(VALUE /*self*/)
{
    return rb_str_new2(WTRUBY_VERSION);
}

static VALUE
set_application_terminated(VALUE /*self*/, VALUE yn)
{
    Wt::Ruby::application_terminated = (yn == Qtrue ? true : false);
    return Qnil;
}

static VALUE
set_wtruby_embedded_wrapped(VALUE /*self*/, VALUE yn)
{
  set_wtruby_embedded(yn == Qtrue);
  return Qnil;
}

static Wt::Ruby::Binding binding;

WTRUBY_EXPORT void
Init_wt()
{
    if (wt_Smoke == 0) {
        init_wt_Smoke();
    }

    Wt::Ruby::smokeList.push_back(wt_Smoke);

    binding = Wt::Ruby::Binding(wt_Smoke);
    Wt::Ruby::Module module = { "wtruby", resolve_classname_wt, 0, &binding };
    Wt::Ruby::modules[wt_Smoke] = module;

    install_handlers(Wt_handlers);

    Wt::Ruby::wt_module = rb_define_module("Wt");
    Wt::Ruby::wt_internal_module = rb_define_module_under(Wt::Ruby::wt_module, "Internal");
    Wt::Ruby::wt_chart_module = rb_define_module_under(Wt::Ruby::wt_module, "Chart");
    Wt::Ruby::wt_base_class = rb_define_class_under(Wt::Ruby::wt_module, "Base", rb_cObject);
    Wt::Ruby::moduleindex_class = rb_define_class_under(Wt::Ruby::wt_internal_module, "ModuleIndex", rb_cObject);
    Wt::Ruby::ruby_stateless_slot_class = rb_define_class_under(Wt::Ruby::wt_module, "RubyStatelessSlot", rb_cObject);

    Wt::Ruby::wt_boost_module = rb_define_module("Boost");
    VALUE wt_boost_signals_module = rb_define_module_under(Wt::Ruby::wt_boost_module, "Signals");

    VALUE wt_std_module = rb_define_module("Std");
    Wt::Ruby::wt_std_ostream_class = rb_define_class_under(wt_std_module, "OStream", rb_cObject);
    rb_define_method(Wt::Ruby::wt_std_ostream_class, "write", (VALUE (*) (...)) wt_std_ostream_write, 1);
    rb_define_method(Wt::Ruby::wt_std_ostream_class, "flush", (VALUE (*) (...)) wt_std_ostream_flush, 0);

    rb_define_singleton_method(Wt::Ruby::wt_base_class, "new", (VALUE (*) (...)) new_wt, -1);
    rb_define_method(Wt::Ruby::wt_base_class, "initialize", (VALUE (*) (...)) initialize_wt, -1);
    rb_define_singleton_method(Wt::Ruby::wt_base_class, "method_missing", (VALUE (*) (...)) class_method_missing, -1);
    rb_define_singleton_method(Wt::Ruby::wt_module, "method_missing", (VALUE (*) (...)) module_method_missing, -1);
    rb_define_singleton_method(Wt::Ruby::wt_chart_module, "method_missing", (VALUE (*) (...)) module_method_missing, -1);
    rb_define_method(Wt::Ruby::wt_base_class, "method_missing", (VALUE (*) (...)) method_missing, -1);

    rb_define_singleton_method(Wt::Ruby::wt_base_class, "const_missing", (VALUE (*) (...)) class_method_missing, -1);
    rb_define_singleton_method(Wt::Ruby::wt_module, "const_missing", (VALUE (*) (...)) module_method_missing, -1);
    rb_define_singleton_method(Wt::Ruby::wt_chart_module, "const_missing", (VALUE (*) (...)) module_method_missing, -1);
    rb_define_method(Wt::Ruby::wt_base_class, "const_missing", (VALUE (*) (...)) method_missing, -1);

    rb_define_method(Wt::Ruby::wt_base_class, "dispose", (VALUE (*) (...)) dispose, 0);
    rb_define_method(Wt::Ruby::wt_base_class, "isDisposed", (VALUE (*) (...)) is_disposed, 0);
    rb_define_method(Wt::Ruby::wt_base_class, "disposed?", (VALUE (*) (...)) is_disposed, 0);

    rb_define_module_function(Wt::Ruby::wt_internal_module, "getMethStat", (VALUE (*) (...)) getMethStat, 0);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "getClassStat", (VALUE (*) (...)) getClassStat, 0);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "getIsa", (VALUE (*) (...)) getIsa, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "setDebug", (VALUE (*) (...)) setDebug, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "debug", (VALUE (*) (...)) debugging, 0);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "get_arg_type_name", (VALUE (*) (...)) get_arg_type_name, 2);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "classIsa", (VALUE (*) (...)) classIsa, 2);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "isEnum", (VALUE (*) (...)) isEnum, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "insert_pclassid", (VALUE (*) (...)) insert_pclassid, 2);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "classid2name", (VALUE (*) (...)) classid2name, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "find_pclassid", (VALUE (*) (...)) find_pclassid, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "get_value_type", (VALUE (*) (...)) get_value_type, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "mapObject", (VALUE (*) (...)) mapObject, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "idInstance", (VALUE (*) (...)) idInstance, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "findClass", (VALUE (*) (...)) findClass, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "findMethod", (VALUE (*) (...)) findMethod, 2);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "findAllMethods", (VALUE (*) (...)) findAllMethods, -1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "findAllMethodNames", (VALUE (*) (...)) findAllMethodNames, 3);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "dumpCandidates", (VALUE (*) (...)) dumpCandidates, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "isObject", (VALUE (*) (...)) isObject, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "setCurrentMethod", (VALUE (*) (...)) setCurrentMethod, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "getClassList", (VALUE (*) (...)) getClassList, 0);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "create_wt_class", (VALUE (*) (...)) create_wt_class, 2);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "set_wtruby_embedded", (VALUE (*) (...)) set_wtruby_embedded_wrapped, 1);
    rb_define_module_function(Wt::Ruby::wt_internal_module, "application_terminated=", (VALUE (*) (...)) set_application_terminated, 1);

    rb_define_module_function(Wt::Ruby::wt_module, "WRun", (VALUE (*) (...)) wt_wrun, 1);
    rb_define_module_function(Wt::Ruby::wt_module, "wtruby_version", (VALUE (*) (...)) wtruby_version, 0);

    rb_require("wt/wtruby.rb");

    // Do package initialization
    rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("init_all_classes"), 0);
}

}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;

