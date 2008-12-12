/***************************************************************************
                          Wt.cpp  -  description
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

#include <stdio.h>
#include <stdarg.h>

#include <boost/regex.hpp>

#include <ruby.h>

#include <smoke/smoke.h>
#include <smoke/wt_smoke.h>

#include "marshall.h"
#include "wtruby.h"
#include "smokeruby.h"
#include "smoke.h"
#include "marshall_types.h"
// #define DEBUG

namespace Wt {
  namespace Ruby {
  
#ifdef DEBUG
int do_debug = wtdb_gc;
#else
int do_debug = wtdb_none;
#endif
    
int object_count = 0;

VALUE wt_internal_module = Qnil;
VALUE wt_module = Qnil;
VALUE wt_boost_module = Qnil;
VALUE wt_chart_module = Qnil;
VALUE wt_base_class = Qnil;
VALUE moduleindex_class = Qnil;

bool application_terminated = false;

typedef std::map<void *, VALUE *> PointerMap;

Modules         modules;
PointerMap      pointerMap;
ClassCache      classcache;
ClassnameMap    classnameMap;

std::vector<Smoke*> smokeList;

int smokeListIndexOf(Smoke * s) {
    for (unsigned int i = 0; i < smokeList.size(); i++) {
        if (smokeList[i] == s) {
            return i;
        }
    }
    return -1;
}

  }
}

#define logger logger_backend


smokeruby_object * 
alloc_smokeruby_object(bool allocated, Smoke * smoke, int classId, void * ptr)
{
    smokeruby_object * o = ALLOC(smokeruby_object);
    o->classId = classId;
    o->smoke = smoke;
    o->ptr = ptr;
    o->allocated = allocated;
    return o;
}

void
free_smokeruby_object(smokeruby_object * o)
{
    xfree(o);
    return;
}

smokeruby_object *value_obj_info(VALUE ruby_value) {  // ptr on success, null on fail
    if (TYPE(ruby_value) != T_DATA) {
        return 0;
    }

    smokeruby_object * o = 0;
    Data_Get_Struct(ruby_value, smokeruby_object, o);
    return o;
}

void *value_to_ptr(VALUE ruby_value) {  // ptr on success, null on fail
    smokeruby_object *o = value_obj_info(ruby_value);
    return o;
}

VALUE getPointerObject(void *ptr) {
    Wt::Ruby::PointerMap::const_iterator i = Wt::Ruby::pointerMap.find(ptr);
    if (i == Wt::Ruby::pointerMap.end()) {
        if (Wt::Ruby::do_debug & wtdb_gc) {
            printf("getPointerObject %p -> nil\n", ptr);
        }
        return Qnil;
    } else {
        if (Wt::Ruby::do_debug & wtdb_gc) {
            printf("getPointerObject %p -> %p\n", ptr, Wt::Ruby::pointerMap[ptr]);
        }
        return *(Wt::Ruby::pointerMap[ptr]);
    }
}

void unmapPointer(smokeruby_object *o, Smoke::Index classId, void *lastptr) {
    void *ptr = o->smoke->cast(o->ptr, o->classId, classId);
    if (ptr != lastptr) {
        lastptr = ptr;
        Wt::Ruby::PointerMap::const_iterator i = Wt::Ruby::pointerMap.find(ptr);
        if (i == Wt::Ruby::pointerMap.end()) {
            VALUE * obj_ptr = Wt::Ruby::pointerMap[ptr];
        
            if (Wt::Ruby::do_debug & wtdb_gc) {
                const char *className = o->smoke->classes[o->classId].className;
                printf("unmapPointer (%s*)%p -> %p size: %d\n", className, ptr, obj_ptr, Wt::Ruby::pointerMap.size() - 1);
            }
        
            Wt::Ruby::pointerMap.erase(ptr);
            xfree((void*) obj_ptr);
        }
    }

    for (Smoke::Index *i = o->smoke->inheritanceList + o->smoke->classes[classId].parents; *i; i++) {
        unmapPointer(o, *i, lastptr);
    }
}

// Store pointer in Wt::Ruby::pointerMap hash : "pointer_to_Qt_object" => weak ref to associated Ruby object
// Recurse to store it also as casted to its parent classes.

void mapPointer(VALUE obj, smokeruby_object *o, Smoke::Index classId, void *lastptr) {
    void *ptr = o->smoke->cast(o->ptr, o->classId, classId);
    
    if (ptr != lastptr) {
        lastptr = ptr;
        VALUE * obj_ptr = ALLOC(VALUE);
        memcpy(obj_ptr, &obj, sizeof(VALUE));
        
        if (Wt::Ruby::do_debug & wtdb_gc) {
            const char *className = o->smoke->classes[o->classId].className;
            printf("mapPointer (%s*)%p -> %p size: %d\n", className, ptr, (void*)obj, Wt::Ruby::pointerMap.size() + 1);
        }
    
        Wt::Ruby::pointerMap[ptr] = obj_ptr;
    }
    
    for (Smoke::Index *i = o->smoke->inheritanceList + o->smoke->classes[classId].parents; *i; i++) {
        mapPointer(obj, o, *i, lastptr);
    }
    
    return;
}

namespace Wt {
  namespace Ruby {

Binding::Binding() : SmokeBinding(0) {}
Binding::Binding(Smoke *s) : SmokeBinding(s) {}

void
Binding::deleted(Smoke::Index classId, void *ptr) {
    VALUE obj = getPointerObject(ptr);
    smokeruby_object *o = value_obj_info(obj);
    if (Wt::Ruby::do_debug & wtdb_gc) {
        printf("%p->~%s()\n", ptr, smoke->className(classId));
    }
    if (!o || !o->ptr) {
        return;
    }
    unmapPointer(o, o->classId, 0);
    o->ptr = 0;
}

bool
Binding::callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool /*isAbstract*/) {
    VALUE obj = getPointerObject(ptr);
    smokeruby_object *o = value_obj_info(obj);

    if (Wt::Ruby::do_debug & wtdb_virtual) {
        Smoke::Method & meth = smoke->methods[method];
        std::string signature(smoke->methodNames[meth.name]);
        signature += "(";
            for (int i = 0; i < meth.numArgs; i++) {
        if (i != 0) signature += ", ";
            signature += smoke->types[smoke->argumentList[meth.args + i]].name;
        }
        signature += ")";
        if (meth.flags & Smoke::mf_const) {
            signature += " const";
        }
        printf(    "module: %s virtual %p->%s::%s called\n", 
                    smoke->moduleName(),
                    ptr,
                    smoke->classes[smoke->methods[method].classId].className,
                    signature.c_str() );
    }

    if (o == 0) {
        if (Wt::Ruby::do_debug & wtdb_virtual) {
            // if not in global destruction
            printf("Cannot find object for virtual method %p -> %p\n", ptr, &obj);
        }
        return false;
    }

    const char *methodName = smoke->methodNames[smoke->methods[method].name];

    // Special case load() at present as it clashes with Kernel#load
    if (std::strcmp(methodName, "load") == 0) {
        return false;
    }

    // If the virtual method hasn't been overriden, just call the C++ one.
    if (rb_respond_to(obj, rb_intern(methodName)) == 0) {
        return false;
    }

    Wt::Ruby::VirtualMethodCall c(smoke, method, args, obj, ALLOCA_N(VALUE, smoke->methods[method].numArgs));
    c.next();
    return true;
}

char *
Binding::className(Smoke::Index classId) {
    Smoke::ModuleIndex mi = { smoke, classId };
    return (char *) (classnameMap[mi])->c_str();
}

  }
}

void rb_str_catf(VALUE self, const char *format, ...) 
{
#define CAT_BUFFER_SIZE 2048
static char p[CAT_BUFFER_SIZE];
    va_list ap;
    va_start(ap, format);
    std::vsnprintf(p, CAT_BUFFER_SIZE, format, ap);
    p[CAT_BUFFER_SIZE - 1] = '\0';
    rb_str_cat2(self, p);
    va_end(ap);
}

const char *
resolve_classname(smokeruby_object * o)
{
    if (o->smoke->classes[o->classId].external) {
        Smoke::ModuleIndex mi = o->smoke->findClass(o->smoke->className(o->classId));
        o->smoke = mi.smoke;
        o->classId = mi.index;
        return Wt::Ruby::modules[mi.smoke].resolve_classname(o);
    }
    return Wt::Ruby::modules[o->smoke].resolve_classname(o);
}

VALUE
findMethod(VALUE /*self*/, VALUE c_value, VALUE name_value)
{
    char *c = StringValuePtr(c_value);
    char *name = StringValuePtr(name_value);
    VALUE result = rb_ary_new();
    Smoke* s = Smoke::classMap[c];
    Smoke::ModuleIndex meth = wt_Smoke->NullModuleIndex;
    if (s != 0) {
        meth = s->findMethod(c, name);
    }
// #ifdef DEBUG
    if (Wt::Ruby::do_debug & wtdb_calls) printf("Found method %s::%s => %d\n", c, name, meth.index);
// #endif
    if (meth.index == 0) {
        // since every smoke module defines a class 'QGlobalSpace' we can't rely on the classMap,
        // so we search for methods by hand
        for (unsigned int i = 0; i < Wt::Ruby::smokeList.size(); i++) {
            Smoke::ModuleIndex cid = Wt::Ruby::smokeList[i]->idClass("QGlobalSpace");
            Smoke::ModuleIndex mnid = Wt::Ruby::smokeList[i]->idMethodName(name);
            if (!cid.index || !mnid.index) continue;
            meth = s->idMethod(cid.index, mnid.index);
            if (meth.index) break;
        }
// #ifdef DEBUG
        if (Wt::Ruby::do_debug & wtdb_calls) printf("Found method QGlobalSpace::%s => %d\n", name, meth.index);
// #endif
    }

    if (meth.index == 0) {
        return result;
        // empty list
    } else if(meth.index > 0) {
        Smoke::Index i = meth.smoke->methodMaps[meth.index].method;
        if (i == 0) {        // shouldn't happen
            rb_raise(rb_eArgError, "Corrupt method %s::%s", c, name);
        } else if(i > 0) {    // single match
            Smoke::Method &methodRef = meth.smoke->methods[i];
            if ((methodRef.flags & Smoke::mf_internal) == 0) {
                rb_ary_push(result, rb_funcall( Wt::Ruby::moduleindex_class, 
                                                rb_intern("new"), 
                                                2, 
                                                INT2NUM(Wt::Ruby::smokeListIndexOf(meth.smoke)), 
                                                INT2NUM(i) ) );
            }
        } else {        // multiple match
            i = -i;        // turn into ambiguousMethodList index
            while (meth.smoke->ambiguousMethodList[i]) {
                Smoke::Method &methodRef = meth.smoke->methods[meth.smoke->ambiguousMethodList[i]];
                if ((methodRef.flags & Smoke::mf_internal) == 0) {
                    rb_ary_push(result, rb_funcall( Wt::Ruby::moduleindex_class, 
                                                    rb_intern("new"), 
                                                    2, 
                                                    INT2NUM(Wt::Ruby::smokeListIndexOf(meth.smoke)), 
                                                    INT2NUM(meth.smoke->ambiguousMethodList[i]) ) );
//#ifdef DEBUG
                    if (Wt::Ruby::do_debug & wtdb_calls) {
                        printf("Ambiguous Method %s::%s => %d\n", c, name, meth.smoke->ambiguousMethodList[i]);
                    }
//#endif
                }
            i++;
            }
        }
    }
    return result;
}

// findAllMethods(ModuleIndex [, startingWith]) : returns { "mungedName" => [index in methods, ...], ... }

VALUE
findAllMethods(int argc, VALUE * argv, VALUE /*self*/)
{
    VALUE rb_mi = argv[0];
    VALUE result = rb_hash_new();
    if (rb_mi != Qnil) {
        Smoke::Index c = (Smoke::Index) NUM2INT(rb_funcall(rb_mi, rb_intern("index"), 0));
        Smoke *smoke = Wt::Ruby::smokeList[NUM2INT(rb_funcall(rb_mi, rb_intern("smoke"), 0))];
        if (c > smoke->numClasses) {
            return Qnil;
        }
        char * pat = 0L;
        if(argc > 1 && TYPE(argv[1]) == T_STRING)
            pat = StringValuePtr(argv[1]);
#ifdef DEBUG
        if (Wt::Ruby::do_debug & wtdb_calls) printf("findAllMethods called with classid = %d, pat == %s\n", c, pat);
#endif
        Smoke::Index imax = smoke->numMethodMaps;
        Smoke::Index imin = 0, icur = -1, methmin, methmax;
        methmin = -1; methmax = -1; // kill warnings
        int icmp = -1;
        while(imax >= imin) {
            icur = (imin + imax) / 2;
            icmp = smoke->leg(smoke->methodMaps[icur].classId, c);
            if (icmp == 0) {
                Smoke::Index pos = icur;
                while (icur && smoke->methodMaps[icur-1].classId == c)
                    icur --;
                methmin = icur;
                icur = pos;
                while(icur < imax && smoke->methodMaps[icur+1].classId == c)
                    icur ++;
                methmax = icur;
                break;
            }
            if (icmp > 0)
                imax = icur - 1;
            else
                imin = icur + 1;
        }
        if (icmp == 0) {
            for (Smoke::Index i = methmin; i <= methmax; i++) {
                Smoke::Index m = smoke->methodMaps[i].name;
                if (pat == 0L || strncmp(smoke->methodNames[m], pat, strlen(pat)) == 0) {
                    Smoke::Index ix = smoke->methodMaps[i].method;
                    VALUE meths = rb_ary_new();
                    if (ix >= 0) {    // single match
                        Smoke::Method &methodRef = smoke->methods[ix];
                        if ((methodRef.flags & Smoke::mf_internal) == 0) {
                            rb_ary_push(meths, rb_funcall(Wt::Ruby::moduleindex_class, rb_intern("new"), 2, INT2NUM(Wt::Ruby::smokeListIndexOf(smoke)), INT2NUM((int) ix)));
                        }
                    } else {        // multiple match
                        ix = -ix;        // turn into ambiguousMethodList index
                        while (smoke->ambiguousMethodList[ix]) {
                            Smoke::Method &methodRef = smoke->methods[smoke->ambiguousMethodList[ix]];
                            if ((methodRef.flags & Smoke::mf_internal) == 0) {
                                rb_ary_push(meths, rb_funcall(  Wt::Ruby::moduleindex_class, 
                                                                rb_intern("new"), 
                                                                2, 
                                                                INT2NUM(Wt::Ruby::smokeListIndexOf(smoke)), 
                                                                INT2NUM((int)smoke->ambiguousMethodList[ix]) ) );
                            }
                            ix++;
                        }
                    }
                    rb_hash_aset(result, rb_str_new2(smoke->methodNames[m]), meths);
                }
            }
        }
    }
    return result;
}

/*
    Flags values
        0                    All methods, except enum values and protected non-static methods
        mf_static            Static methods only
        mf_enum                Enums only
        mf_protected        Protected non-static methods only
*/

#define PUSH_WTRUBY_METHOD        \
        if (    (methodRef.flags & (Smoke::mf_internal|Smoke::mf_ctor|Smoke::mf_dtor)) == 0 \
                && strcmp(wt_Smoke->methodNames[methodRef.name], "operator=") != 0 \
                && strcmp(wt_Smoke->methodNames[methodRef.name], "operator!=") != 0 \
                && strcmp(wt_Smoke->methodNames[methodRef.name], "operator--") != 0 \
                && strcmp(wt_Smoke->methodNames[methodRef.name], "operator++") != 0 \
                && strncmp(wt_Smoke->methodNames[methodRef.name], "operator ", strlen("operator ")) != 0 \
                && (    (flags == 0 && (methodRef.flags & (Smoke::mf_static|Smoke::mf_enum|Smoke::mf_protected)) == 0) \
                        || (    flags == Smoke::mf_static \
                                && (methodRef.flags & Smoke::mf_enum) == 0 \
                                && (methodRef.flags & Smoke::mf_static) == Smoke::mf_static ) \
                        || (flags == Smoke::mf_enum && (methodRef.flags & Smoke::mf_enum) == Smoke::mf_enum) \
                        || (    flags == Smoke::mf_protected \
                                && (methodRef.flags & Smoke::mf_static) == 0 \
                                && (methodRef.flags & Smoke::mf_protected) == Smoke::mf_protected ) ) ) { \
            boost::cmatch what; \
            if (strncmp(wt_Smoke->methodNames[methodRef.name], "operator", strlen("operator")) == 0) { \
                if (boost::regex_match(wt_Smoke->methodNames[methodRef.name], what, op_re)) { \
                    rb_ary_push(result, rb_str_new2((std::string(what[1]) + what[2]).c_str())); \
                } else { \
                    rb_ary_push(result, rb_str_new2(wt_Smoke->methodNames[methodRef.name] + strlen("operator"))); \
                } \
            } else if (boost::regex_match(wt_Smoke->methodNames[methodRef.name], what, predicate_re) && methodRef.numArgs == 0) { \
                std::string predicate(what[2]); \
                predicate[0] = std::tolower(predicate[0]); \
                rb_ary_push(result, rb_str_new2((predicate + what[3] + "?").c_str())); \
            } else if (boost::regex_match(wt_Smoke->methodNames[methodRef.name], what, set_re) && methodRef.numArgs == 1) { \
                std::string set_method(what[2]); \
                set_method[0] = std::tolower(set_method[0]); \
                rb_ary_push(result, rb_str_new2((set_method + what[3] + "=").c_str())); \
            } else { \
                rb_ary_push(result, rb_str_new2(wt_Smoke->methodNames[methodRef.name])); \
            } \
        }
 
VALUE
findAllMethodNames(VALUE /*self*/, VALUE result, VALUE classid, VALUE flags_value)
{
    boost::regex predicate_re("^(is|has)(.)(.*)");
    boost::regex set_re("^(set)([A-Z])(.*)");
    boost::regex op_re("operator(.*)(([-%~/+|&*])|(>>)|(<<)|(&&)|(\\|\\|)|(\\*\\*))=$");

    unsigned short flags = (unsigned short) NUM2UINT(flags_value);
    if (classid != Qnil) {
        Smoke::Index c = (Smoke::Index) NUM2INT(rb_funcall(classid, rb_intern("index"), 0));
        Smoke* s = Wt::Ruby::smokeList[NUM2INT(rb_funcall(classid, rb_intern("smoke"), 0))];
        if (c > s->numClasses) {
            return Qnil;
        }
#ifdef DEBUG
        if (Wt::Ruby::do_debug & wtdb_calls) printf("findAllMethodNames called with classid = %d in module %s"\n, c, s->moduleName());
#endif
        Smoke::Index imax = s->numMethodMaps;
        Smoke::Index imin = 0, icur = -1, methmin, methmax;
        methmin = -1; methmax = -1; // kill warnings
        int icmp = -1;

        while (imax >= imin) {
            icur = (imin + imax) / 2;
            icmp = s->leg(s->methodMaps[icur].classId, c);
            if (icmp == 0) {
                Smoke::Index pos = icur;
                while(icur && s->methodMaps[icur-1].classId == c)
                    icur --;
                methmin = icur;
                icur = pos;
                while(icur < imax && s->methodMaps[icur+1].classId == c)
                    icur ++;
                methmax = icur;
                break;
            }
            if (icmp > 0)
                imax = icur - 1;
            else
                imin = icur + 1;
        }

        if (icmp == 0) {
             for (Smoke::Index i=methmin ; i <= methmax ; i++) {
                Smoke::Index ix= s->methodMaps[i].method;
                if (ix >= 0) {    // single match
                    Smoke::Method &methodRef = s->methods[ix];
                    PUSH_WTRUBY_METHOD
                } else {        // multiple match
                    ix = -ix;        // turn into ambiguousMethodList index
                    while (s->ambiguousMethodList[ix]) {
                        Smoke::Method &methodRef = s->methods[s->ambiguousMethodList[ix]];
                        PUSH_WTRUBY_METHOD
                        ix++;
                    }
                }
            }
        }
    }
    return result;
}

extern "C"
{
// ----------------   Helpers -------------------

//---------- All functions except fully qualified statics & enums ---------

VALUE
mapObject(VALUE self, VALUE obj)
{
    smokeruby_object *o = value_obj_info(obj);
    if (o == 0) {
        return Qnil;
    }
    mapPointer(obj, o, o->classId, 0);
    return self;
}

VALUE set_obj_info(const char * className, smokeruby_object * o);


VALUE
set_obj_info(const char * className, smokeruby_object * o)
{
    VALUE klass = rb_funcall(   Wt::Ruby::wt_internal_module,
                                rb_intern("find_class"),
                                1,
                                rb_str_new2(className) );
    if (klass == Qnil) {
        rb_raise(rb_eRuntimeError, "Class '%s' not found", className);
    }

    Smoke::ModuleIndex *r = Wt::Ruby::classcache[className];
    if (r != 0) {
        o->classId = (int) r->index;
    }

    VALUE obj = Data_Wrap_Struct(klass, smokeruby_mark, smokeruby_free, (void *) o);
    return obj;
}

VALUE pretty_print_method(Smoke::Index id) 
{
    VALUE r = rb_str_new2("");
    Smoke::Method &meth = wt_Smoke->methods[id];
    const char *tname = wt_Smoke->types[meth.ret].name;
    if (meth.flags & Smoke::mf_static) {
        rb_str_catf(r, "static ");
    }
    rb_str_catf(r, "%s ", (tname ? tname:"void"));
    rb_str_catf(r, "%s::%s(", wt_Smoke->classes[meth.classId].className, wt_Smoke->methodNames[meth.name]);
    for (int i = 0; i < meth.numArgs; i++) {
        if (i != 0) {
            rb_str_catf(r, ", ");
        }
        tname = wt_Smoke->types[wt_Smoke->argumentList[meth.args+i]].name;
        rb_str_catf(r, "%s", (tname ? tname:"void"));
    }
    rb_str_catf(r, ")");
    if (meth.flags & Smoke::mf_const) {
        rb_str_catf(r, " const");
    }
    return r;
}

}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
