/***************************************************************************
                          wtruby.h  -  description
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

#ifndef WTRUBY_H
#define WTRUBY_H

#include <map>
#include <vector>
#include <boost/config.hpp>

#include <smoke/smoke.h>

#include "marshall.h"

#define WTRUBY_VERSION "0.9.0"

#if !defined RSTRING_LEN
#define RSTRING_LEN(a) RSTRING(a)->len
#endif
#if !defined RSTRING_PTR
#define RSTRING_PTR(a) RSTRING(a)->ptr
#endif
#if !defined RARRAY_LEN
#define RARRAY_LEN(a) RARRAY(a)->len
#endif
#if !defined RARRAY_PTR
#define RARRAY_PTR(a) RARRAY(a)->ptr
#endif

#ifdef WIN32
  #define WTRUBY_IMPORT __declspec(dllimport)
  #define WTRUBY_EXPORT __declspec(dllexport)
  #define WTRUBY_DLLLOCAL
  #define WTRUBY_DLLPUBLIC
#else
  #ifdef GCC_HASCLASSVISIBILITY
    #define WTRUBY_IMPORT __attribute__ ((visibility("default")))
    #define WTRUBY_EXPORT __attribute__ ((visibility("default")))
    #define WTRUBY_DLLLOCAL __attribute__ ((visibility("hidden")))
    #define WTRUBY_DLLPUBLIC __attribute__ ((visibility("default")))
  #else
    #define WTRUBY_IMPORT
    #define WTRUBY_EXPORT
    #define WTRUBY_DLLLOCAL
    #define WTRUBY_DLLPUBLIC
  #endif
#endif

inline bool operator==(const Smoke::ModuleIndex& a, const Smoke::ModuleIndex& b) {
    return a.index == b.index && a.smoke == b.smoke;
}

inline bool operator<(const Smoke::ModuleIndex& a, const Smoke::ModuleIndex& b) {
    return a.smoke < b.smoke || (a.smoke == b.smoke && a.index < b.index);
}

struct smokeruby_object {
    void *ptr;
    bool allocated;
    Smoke *smoke;
    int classId;
};

struct TypeHandler {
    const char *name;
    Marshall::HandlerFn fn;
};


namespace Wt {
  namespace Ruby {

typedef const char* (*ResolveClassNameFn)(smokeruby_object * o);
typedef void (*ClassCreatedFn)(const char* package, VALUE module, VALUE klass);

class WTRUBY_EXPORT Binding : public SmokeBinding {
public:
    Binding();
    Binding(Smoke *s);
    void deleted(Smoke::Index classId, void *ptr);
    bool callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool /*isAbstract*/);
    char * className(Smoke::Index classId);
};

struct Module {
    const char *name;
    ResolveClassNameFn resolve_classname;
    ClassCreatedFn class_created;
    Binding *binding;
};

extern WTRUBY_EXPORT TypeHandler type_handlers[];

typedef std::map<Smoke*, Wt::Ruby::Module> Modules;
typedef std::map<std::string, Smoke::ModuleIndex *> ClassCache;
typedef std::map<Smoke::ModuleIndex, std::string*> ClassnameMap;

extern WTRUBY_EXPORT Modules modules;
extern WTRUBY_EXPORT ClassCache classcache;

// Maps from an int id to classname in Ruby
extern WTRUBY_EXPORT ClassnameMap IdToClassNameMap;

extern WTRUBY_EXPORT std::vector<Smoke*> smokeList;
extern WTRUBY_EXPORT int smokeListIndexOf(Smoke * s);

extern WTRUBY_EXPORT VALUE eventsignal_void_class;
extern WTRUBY_EXPORT VALUE eventsignal_wkey_event_class;
extern WTRUBY_EXPORT VALUE eventsignal_wmouse_event_class;
extern WTRUBY_EXPORT VALUE eventsignal_wresponse_event_class;

extern WTRUBY_EXPORT VALUE jsignal_class;
extern WTRUBY_EXPORT VALUE jsignal1_class;
extern WTRUBY_EXPORT VALUE jsignal2_class;
extern WTRUBY_EXPORT VALUE jsignal_boolean_class;
extern WTRUBY_EXPORT VALUE jsignal_int_class;
extern WTRUBY_EXPORT VALUE jsignal_int_int_class;

extern WTRUBY_EXPORT VALUE signal_class;
extern WTRUBY_EXPORT VALUE signal1_class;
extern WTRUBY_EXPORT VALUE signal2_class;
extern WTRUBY_EXPORT VALUE signal_boolean_class;
extern WTRUBY_EXPORT VALUE signal_int_class;
extern WTRUBY_EXPORT VALUE signal_int_int_class;
extern WTRUBY_EXPORT VALUE signal_int_int_int_int_class;
extern WTRUBY_EXPORT VALUE signal_longlong_longlong_class;
extern WTRUBY_EXPORT VALUE signal_enum_class;
extern WTRUBY_EXPORT VALUE signal_wmenuitem_class;
extern WTRUBY_EXPORT VALUE signal_wwidget_class;
extern WTRUBY_EXPORT VALUE signal_wmodelindex_wmouseevent_class;
extern WTRUBY_EXPORT VALUE signal_wstring_class;
extern WTRUBY_EXPORT VALUE signal_string_class;
extern WTRUBY_EXPORT VALUE signal_string_string_class;

extern WTRUBY_EXPORT int do_debug;   // evil
extern WTRUBY_EXPORT int object_count;

extern WTRUBY_EXPORT VALUE wt_internal_module;
extern WTRUBY_EXPORT VALUE wt_module;
extern WTRUBY_EXPORT VALUE wt_boost_module;
extern WTRUBY_EXPORT VALUE wt_std_ostream_class;
extern WTRUBY_EXPORT VALUE wt_chart_module;
extern WTRUBY_EXPORT VALUE wt_base_class;
extern WTRUBY_EXPORT VALUE moduleindex_class;

extern WTRUBY_EXPORT bool application_terminated;

extern WTRUBY_EXPORT void * construct_copy(smokeruby_object *o);

  }
}

// keep this enum in sync with lib/Wt/wtruby.rb

enum WtDebugChannel {
    wtdb_none = 0x00,
    wtdb_ambiguous = 0x01,
    wtdb_method_missing = 0x02,
    wtdb_calls = 0x04,
    wtdb_gc = 0x08,
    wtdb_virtual = 0x10,
    wtdb_verbose = 0x20
};

extern "C" {
extern WTRUBY_EXPORT void set_wtruby_embedded(bool yn);
}

extern WTRUBY_EXPORT void install_handlers(TypeHandler *);

extern WTRUBY_EXPORT void smokeruby_mark(void * ptr);
extern WTRUBY_EXPORT void smokeruby_free(void * ptr);

extern WTRUBY_EXPORT smokeruby_object * alloc_smokeruby_object(bool allocated, Smoke * smoke, int classId, void * ptr);
extern WTRUBY_EXPORT void free_smokeruby_object(smokeruby_object * o);
extern WTRUBY_EXPORT smokeruby_object *value_obj_info(VALUE value);
extern WTRUBY_EXPORT void *value_to_ptr(VALUE ruby_value); // ptr on success, null on fail

extern WTRUBY_EXPORT VALUE getPointerObject(void *ptr);
extern WTRUBY_EXPORT void mapPointer(VALUE obj, smokeruby_object *o, Smoke::Index classId, void *lastptr);
extern WTRUBY_EXPORT void unmapPointer(smokeruby_object *, Smoke::Index, void*);

extern WTRUBY_EXPORT const char * resolve_classname(smokeruby_object * o);
extern WTRUBY_EXPORT VALUE rb_str_catf(VALUE self, const char *format, ...) __attribute__ ((format (printf, 2, 3)));

extern WTRUBY_EXPORT VALUE findMethod(VALUE self, VALUE c_value, VALUE name_value);
extern WTRUBY_EXPORT VALUE findAllMethods(int argc, VALUE * argv, VALUE self);
extern WTRUBY_EXPORT VALUE findAllMethodNames(VALUE self, VALUE result, VALUE classid, VALUE flags_value);

extern "C"
{
extern WTRUBY_EXPORT VALUE mapObject(VALUE self, VALUE obj);
extern WTRUBY_EXPORT VALUE set_obj_info(const char * className, smokeruby_object * o);
extern WTRUBY_EXPORT VALUE pretty_print_method(Smoke::Index id);
}

#endif

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;

