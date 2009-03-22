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

#include <Wt/WJavaScript>
#include <Wt/WObject>
#include <Wt/WWidget>
#include <Wt/WDate>
#include <Wt/WDialog>
#include <Wt/WMenuItem>
#include <Wt/WModelIndex>
#include <Wt/WEvent>
#include <Wt/WStandardItem>
#include <Wt/WApplication>

#if WT_VERSION >= 0x0299000000
#include <Wt/WGoogleMap>
#endif

#include <smoke/smoke.h>
#include <smoke/wt_smoke.h>
#include <ruby.h>

#include "marshall_types.h"
#include "wtruby.h"

namespace Wt {
  namespace Ruby {

class SlotInvocation : public Wt::WObject {
public:
    SlotInvocation(Wt::WObject * parent, VALUE target, VALUE method, VALUE undoMethod = Qnil) 
        : Wt::WObject(parent), target_(target), method_(method), undoMethod_(undoMethod)
    {
    }

    virtual ~SlotInvocation() {
    }

    void undo() {
        if (Wt::Ruby::do_debug & wtdb_calls) {
            VALUE target_name = rb_funcall(target_, rb_intern("to_s"), 0);
            VALUE method_name = rb_funcall(undoMethod_, rb_intern("to_s"), 0);

            printf( "SlotInvocation::undo() calling %s#%s\n", 
                    StringValuePtr(target_name), 
                    StringValuePtr(method_name) );
        }
        
        rb_funcall(target_, SYM2ID(undoMethod_), 0);
    }

    void invoke() {
        if (Wt::Ruby::do_debug & wtdb_calls) {
            VALUE target_name = rb_funcall(target_, rb_intern("to_s"), 0);
            VALUE method_name = rb_funcall(method_, rb_intern("to_s"), 0);

            printf( "SlotInvocation::invoke() calling %s#%s\n", 
                    StringValuePtr(target_name), 
                    StringValuePtr(method_name) );
        }
        
        rb_funcall(target_, SYM2ID(method_), 0);
    }

    void invoke1(VALUE arg) {
        rb_funcall(target_, SYM2ID(method_), 1, arg);
    }

    void invoke2(VALUE arg1, VALUE arg2) {
        rb_funcall(target_, SYM2ID(method_), 2, arg1, arg2);
    }

    void invoke1(bool arg) {
        rb_funcall(target_, SYM2ID(method_), 1, arg ? Qtrue : Qfalse);
    }

    void invoke1(Wt::WDialog::DialogCode arg) {
        rb_funcall(target_, SYM2ID(method_), 1, INT2NUM(arg));
    }

    void invoke1(Wt::Orientation arg) {
        rb_funcall(target_, SYM2ID(method_), 1, INT2NUM(arg));
    }

    void invoke1(Wt::WDate arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WDate").index, 
                                                        static_cast<void*>(new Wt::WDate(arg)) );
        VALUE obj = set_obj_info("Wt::WDate", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

#if WT_VERSION >= 0x02990000
    void invoke1(Wt::WGoogleMap::Coordinate arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WGoogleMap::Coordinate").index, 
                                                        static_cast<void*>(new Wt::WGoogleMap::Coordinate(arg)) );
        VALUE obj = set_obj_info("Wt::WGoogleMap::Coordinate", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }
#endif

    void invoke1(Wt::WKeyEvent arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WKeyEvent").index, 
                                                        static_cast<void*>(new Wt::WKeyEvent(arg)) );
        VALUE obj = set_obj_info("Wt::WKeyEvent", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WMenuItem * arg) {
        VALUE obj = getPointerObject((void *) arg);
        if (obj == Qnil) {
            smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WMenuItem").index, 
                                                            (void *) arg );
            obj = set_obj_info("Wt::WMenuItem", o);
        }

        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WMouseEvent arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WMouseEvent").index, 
                                                        static_cast<void*>(new Wt::WMouseEvent(arg)) );
        VALUE obj = set_obj_info("Wt::WMouseEvent", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WResponseEvent arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WResponseEvent").index, 
                                                        static_cast<void*>(new Wt::WResponseEvent(arg)) );
        VALUE obj = set_obj_info("Wt::WResponseEvent", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WScrollEvent arg) {
        smokeruby_object * o = alloc_smokeruby_object(  true, 
                                                        wt_Smoke, 
                                                        wt_Smoke->idClass("Wt::WScrollEvent").index, 
                                                        static_cast<void*>(new Wt::WScrollEvent(arg)) );
        VALUE obj = set_obj_info("Wt::WScrollEvent", o);
        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WWidget * arg) {
        VALUE obj = getPointerObject((void *) arg);
        if (obj == Qnil) {
            smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WWidget").index, 
                                                            (void *) arg );
            obj = set_obj_info("Wt::WWidget", o);
        }

        rb_funcall(target_, SYM2ID(method_), 1, obj);
    }

    void invoke1(Wt::WStandardItem * arg1) {
        VALUE obj1 = getPointerObject((void *) arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( false, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WStandardItem").index, 
                                                            (void *) arg1 );
            obj1 = set_obj_info("Wt::WStandardItem", o1);
        }

        rb_funcall(target_, SYM2ID(method_), 1, obj1);
    }

    void invoke1(Wt::WModelIndex arg1) {
        VALUE obj1 = getPointerObject((void *) &arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg1)) );
            obj1 = set_obj_info("Wt::WModelIndex", o1);
        }

        rb_funcall(target_, SYM2ID(method_), 1, obj1);
    }

    void invoke2(Wt::WModelIndex arg1, int arg2) {
        VALUE obj1 = getPointerObject((void *) &arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg1)) );
            obj1 = set_obj_info("Wt::WModelIndex", o1);
        }

        rb_funcall(target_, SYM2ID(method_), 2, obj1, INT2NUM(arg2));
    }

    void invoke2(Wt::WModelIndex arg1, Wt::WModelIndex arg2) {
        VALUE obj1 = getPointerObject((void *) &arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg1)) );
            obj1 = set_obj_info("Wt::WModelIndex", o1);
        }

        VALUE obj2 = getPointerObject((void *) &arg2);
        if (obj2 == Qnil) {
            smokeruby_object * o2 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg2)) );
            obj2 = set_obj_info("Wt::WModelIndex", o2);
        }

        rb_funcall(target_, SYM2ID(method_), 2, obj1, obj2);
    }

    void invoke2(Wt::WModelIndex arg1, Wt::WMouseEvent arg2) {
        VALUE obj1 = getPointerObject((void *) &arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg1)) );
            obj1 = set_obj_info("Wt::WModelIndex", o1);
        }

        VALUE obj2 = getPointerObject((void *) &arg2);
        if (obj2 == Qnil) {
            smokeruby_object * o2 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WMouseEvent").index, 
                                                            static_cast<void*>(new Wt::WMouseEvent(arg2)) );
            obj2 = set_obj_info("Wt::WMouseEvent", o2);
        }

        rb_funcall(target_, SYM2ID(method_), 2, obj1, obj2);
    }

    void invoke1(Wt::StandardButton arg) {
        rb_funcall(target_, SYM2ID(method_), 1, INT2NUM(arg));
    }

    void invoke1(double arg) {
        rb_funcall(target_, SYM2ID(method_), 1, rb_float_new(arg));
    }

    void invoke1(Wt::WString arg) {
        rb_funcall(target_, SYM2ID(method_), 1, rb_str_new2(arg.toUTF8().c_str()));
    }

    void invoke1(std::string arg) {
        rb_funcall(target_, SYM2ID(method_), 1, rb_str_new2(arg.c_str()));
    }

    void invoke2(std::string arg1, std::string arg2) {
        rb_funcall(target_, SYM2ID(method_), 2, rb_str_new2(arg1.c_str()), rb_str_new2(arg2.c_str()));
    }

    void invoke1(int arg) {
        rb_funcall(target_, SYM2ID(method_), 1, INT2NUM(arg));
    }

    void invoke2(int arg1, int arg2) {
        rb_funcall(target_, SYM2ID(method_), 2, INT2NUM(arg1), INT2NUM(arg2));
    }

    void invoke2(Wt::Orientation arg1, int arg2) {
        rb_funcall(target_, SYM2ID(method_), 2, INT2NUM(arg1), INT2NUM(arg2));
    }

    void invoke3(int arg1, int arg2, int arg3) {
        rb_funcall(target_, SYM2ID(method_), 3, INT2NUM(arg1), INT2NUM(arg2), INT2NUM(arg3));
    }

    void invoke3(Wt::Orientation arg1, int arg2, int arg3) {
        rb_funcall(target_, SYM2ID(method_), 3, INT2NUM(arg1), INT2NUM(arg2), INT2NUM(arg3));
    }

    void invoke3(Wt::WModelIndex arg1, int arg2, int arg3) {
        VALUE obj1 = getPointerObject((void *) &arg1);
        if (obj1 == Qnil) {
            smokeruby_object * o1 = alloc_smokeruby_object( true, 
                                                            wt_Smoke, 
                                                            wt_Smoke->idClass("Wt::WModelIndex").index, 
                                                            static_cast<void*>(new Wt::WModelIndex(arg1)) );
            obj1 = set_obj_info("Wt::WModelIndex", o1);
        }

        rb_funcall(target_, SYM2ID(method_), 2, obj1, INT2NUM(arg2), INT2NUM(arg3));
    }

    void invoke4(int arg1, int arg2, int arg3, int arg4) {
        rb_funcall(target_, SYM2ID(method_), 4, INT2NUM(arg1), INT2NUM(arg2), INT2NUM(arg3), INT2NUM(arg4));
    }

    void invoke1(long long arg) {
        rb_funcall(target_, SYM2ID(method_), 2, LL2NUM(arg));
    }

    void invoke2(long long arg1, long long arg2) {
        rb_funcall(target_, SYM2ID(method_), 2, LL2NUM(arg1), LL2NUM(arg2));
    }

    static Wt::WObject * toWObject(VALUE obj) {
        smokeruby_object * p = value_obj_info(obj);
        if (p == 0 || p->ptr == 0) {
            return 0;
        }
        void * ptr = p->smoke->cast(p->ptr, p->classId, p->smoke->idClass("Wt::WObject").index);
        return static_cast<Wt::WObject *>(ptr);
    }
private:
    VALUE target_;
    VALUE method_;
    VALUE undoMethod_;
};

template <class T> 
static void signal_connect(VALUE self, VALUE args) {
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    T * sig = static_cast<T*>(o->ptr);

    SlotInvocation * invocation = new SlotInvocation(   SlotInvocation::toWObject(target), 
                                                        target, 
                                                        method );
    sig->connect(SLOT(invocation, SlotInvocation::invoke));
}

template <class S> 
static void signal_connect1(VALUE self, VALUE args) {
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);
    int arity = NUM2INT(rb_ary_entry(args, 2));

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S*>(o->ptr);

    SlotInvocation * invocation = new SlotInvocation(   SlotInvocation::toWObject(target), 
                                                        target, 
                                                        method );
    switch (arity) {
    case 0:
        sig->connect(SLOT(invocation, SlotInvocation::invoke));
        break;
    case 1:
        sig->connect(SLOT(invocation, SlotInvocation::invoke1));
        break;
    }
}

template <class S> 
static void signal_connect2(VALUE self, VALUE args) {
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);
    int arity = NUM2INT(rb_ary_entry(args, 2));

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S*>(o->ptr);

    SlotInvocation * invocation = new SlotInvocation(   SlotInvocation::toWObject(target), 
                                                        target, 
                                                        method );
    switch (arity) {
    case 0:
        sig->connect(SLOT(invocation, SlotInvocation::invoke));
        break;
    case 1:
        sig->connect(SLOT(invocation, SlotInvocation::invoke1));
        break;
    case 2:
        sig->connect(SLOT(invocation, SlotInvocation::invoke2));
        break;
    }
}

template <class S> 
static void signal_connect3(VALUE self, VALUE args) {
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);
    int arity = NUM2INT(rb_ary_entry(args, 2));

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S*>(o->ptr);

    SlotInvocation * invocation = new SlotInvocation(   SlotInvocation::toWObject(target), 
                                                        target, 
                                                        method );
    switch (arity) {
    case 0:
        sig->connect(SLOT(invocation, SlotInvocation::invoke));
        break;
    case 1:
        sig->connect(SLOT(invocation, SlotInvocation::invoke1));
        break;
    case 2:
        sig->connect(SLOT(invocation, SlotInvocation::invoke2));
        break;
    case 3:
        sig->connect(SLOT(invocation, SlotInvocation::invoke3));
        break;
    }
}

template <class S> 
static void signal_connect4(VALUE self, VALUE args) {
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);
    int arity = NUM2INT(rb_ary_entry(args, 2));

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S*>(o->ptr);

    SlotInvocation * invocation = new SlotInvocation(   SlotInvocation::toWObject(target), 
                                                        target, 
                                                        method );
    switch (arity) {
    case 0:
        sig->connect(SLOT(invocation, SlotInvocation::invoke));
        break;
    case 1:
        sig->connect(SLOT(invocation, SlotInvocation::invoke1));
        break;
    case 2:
        sig->connect(SLOT(invocation, SlotInvocation::invoke2));
        break;
    case 3:
        sig->connect(SLOT(invocation, SlotInvocation::invoke3));
        break;
    case 4:
        sig->connect(SLOT(invocation, SlotInvocation::invoke4));
        break;
    }
}

template <class S, class A1> 
static void signal_emit1(VALUE self, VALUE arg1) {
    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S *>(o->ptr);
    smokeruby_object * a1 = value_obj_info(arg1);
    sig->emit(*(static_cast<A1 *>(a1->ptr)));
}

template <class S, class A1, class A2> 
static void signal_emit2(VALUE self, VALUE arg1, VALUE arg2) {
    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }
    S * sig = static_cast<S *>(o->ptr);
    smokeruby_object * a1 = value_obj_info(arg1);
    smokeruby_object * a2 = value_obj_info(arg2);
    sig->emit(*(static_cast<A1 *>(a1->ptr)), *(static_cast<A2 *>(a1->ptr)));
}

/*
 * When an EventSignal is connected to a slot with arity zero, then check for
 * whether the target ruby slot is stateless. If so, set the slot for the 
 * SlotInvocation::invoke(), and optionally the undo() call, as stateless with
 * implementStateless().
 */
template <class S>
static void eventsignal_connect(VALUE self, VALUE args)
{
    VALUE target = rb_ary_entry(args, 0);
    VALUE method = rb_ary_entry(args, 1);

    SlotInvocation * invocation = 0;
    VALUE statelessSlot = rb_funcall(target, rb_intern("isStateless"), 1, method);

    if (statelessSlot != Qnil) {
        VALUE undoMethod = rb_funcall(statelessSlot, rb_intern("undoMethod"), 0);
        invocation = new SlotInvocation(    SlotInvocation::toWObject(target), 
                                            target, 
                                            method,
                                            undoMethod );
        if (undoMethod != Qnil) {
            invocation->implementStateless(&SlotInvocation::invoke, &SlotInvocation::undo);
        } else {
            invocation->implementStateless(&SlotInvocation::invoke);
        }
    } else {
        invocation = new SlotInvocation(    SlotInvocation::toWObject(target), 
                                            target, 
                                            method );
    }

    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return;
    }

    S * sig = static_cast<S*>(o->ptr);
    sig->connect(SLOT(invocation, SlotInvocation::invoke));
    return;
}

  }
}

static VALUE
eventsignal_void_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::eventsignal_connect< Wt::EventSignal<void> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
eventsignal_void_emit(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::EventSignal<void> * sig = static_cast<Wt::EventSignal<void> * >(o->ptr);
    sig->emit();
    return self;
}

static VALUE
eventsignal_wkey_event_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        int arity = NUM2INT(rb_ary_entry(argv[0], 2));
        if (arity == 0) {
            Wt::Ruby::eventsignal_connect< Wt::EventSignal<Wt::WKeyEvent> >(self, argv[0]);
        } else {
            Wt::Ruby::signal_connect1< Wt::EventSignal<Wt::WKeyEvent> >(self, argv[0]);
        }

        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
eventsignal_wkey_event_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::EventSignal<Wt::WKeyEvent>, Wt::WKeyEvent>(self, arg);
}

static VALUE
eventsignal_wmouse_event_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        int arity = NUM2INT(rb_ary_entry(argv[0], 2));
        if (arity == 0) {
            Wt::Ruby::eventsignal_connect< Wt::EventSignal<Wt::WMouseEvent> >(self, argv[0]);
        } else {
            Wt::Ruby::signal_connect1< Wt::EventSignal<Wt::WMouseEvent> >(self, argv[0]);
        }

        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
eventsignal_wmouse_event_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::EventSignal<Wt::WMouseEvent>, Wt::WMouseEvent>(self, arg);
    return self;
}

static VALUE
eventsignal_wresponse_event_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        int arity = NUM2INT(rb_ary_entry(argv[0], 2));
        if (arity == 0) {
            Wt::Ruby::eventsignal_connect< Wt::EventSignal<Wt::WResponseEvent> >(self, argv[0]);
        } else {
            Wt::Ruby::signal_connect1< Wt::EventSignal<Wt::WResponseEvent> >(self, argv[0]);
        }

        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
eventsignal_wresponse_event_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::EventSignal<Wt::WResponseEvent>, Wt::WResponseEvent>(self, arg);
    return self;
}


static VALUE
eventsignal_wscroll_event_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        int arity = NUM2INT(rb_ary_entry(argv[0], 2));
        if (arity == 0) {
            Wt::Ruby::eventsignal_connect< Wt::EventSignal<Wt::WScrollEvent> >(self, argv[0]);
        } else {
            Wt::Ruby::signal_connect1< Wt::EventSignal<Wt::WScrollEvent> >(self, argv[0]);
        }

        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
eventsignal_wscroll_event_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::EventSignal<Wt::WScrollEvent>, Wt::WScrollEvent>(self, arg);
    return self;
}

static VALUE
new_jsignal(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<void> * sig = new Wt::JSignal<void>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<void> * sig = static_cast<Wt::JSignal<void> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect< Wt::JSignal<void> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal_emit(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<void> * sig = static_cast<Wt::JSignal<void> * >(o->ptr);
    sig->emit();
    return self;
}

static VALUE
new_jsignal1(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<std::string> * sig = new Wt::JSignal<std::string>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal1_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal1_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<std::string> * sig = static_cast<Wt::JSignal<std::string> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal1_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::JSignal<std::string> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal1_emit(VALUE self, VALUE arg)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<std::string> * sig = static_cast<Wt::JSignal<std::string> * >(o->ptr);
    sig->emit(std::string(StringValuePtr(arg)));
    return self;
}

static VALUE
new_jsignal2(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<std::string, std::string> * sig = new Wt::JSignal<std::string, std::string>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal2_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal2_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<std::string, std::string> * sig = static_cast<Wt::JSignal<std::string, std::string> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal2_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::JSignal<std::string, std::string> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal2_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<std::string, std::string> * sig = static_cast<Wt::JSignal<std::string, std::string> * >(o->ptr);
    sig->emit(std::string(StringValuePtr(arg1)), std::string(StringValuePtr(arg2)));
    return self;
}

static VALUE
new_jsignal_boolean(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<bool> * sig = new Wt::JSignal<bool>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal_boolean_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal_boolean_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<bool> * sig = static_cast<Wt::JSignal<bool> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal_boolean_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::JSignal<bool> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal_boolean_emit(VALUE self, VALUE arg)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<bool> * sig = static_cast<Wt::JSignal<bool> * >(o->ptr);
    sig->emit(arg == Qtrue ? true : false);
    return self;
}

static VALUE
new_jsignal_int(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<int> * sig = new Wt::JSignal<int>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal_int_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal_int_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<int> * sig = static_cast<Wt::JSignal<int> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::JSignal<int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal_int_emit(VALUE self, VALUE arg)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<int> * sig = static_cast<Wt::JSignal<int> * >(o->ptr);
    sig->emit(NUM2INT(arg));
    return self;
}

static VALUE
new_jsignal_int_int(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<int, int> * sig = new Wt::JSignal<int, int>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal_int_int_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal_int_int_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<int, int> * sig = static_cast<Wt::JSignal<int, int> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal_int_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::JSignal<int, int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal_int_int_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<int, int> * sig = static_cast<Wt::JSignal<int, int> * >(o->ptr);
    sig->emit(NUM2INT(arg1), NUM2INT(arg2));
    return self;
}

#if WT_VERSION >= 0x02990000
static VALUE
new_jsignal_wgooglemap_coordinate(int argc, VALUE * argv, VALUE klass)
{
    smokeruby_object * o = value_obj_info(argv[0]);
    Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);

    Wt::JSignal<Wt::WGoogleMap::Coordinate> * sig = new Wt::JSignal<Wt::WGoogleMap::Coordinate>(wobject, std::string(StringValuePtr(argv[1])));
    smokeruby_object  * s = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::EventSignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::jsignal_wgooglemap_coordinate_class, smokeruby_mark, smokeruby_free, s);
    mapObject(result, result);
    return result;
}

static VALUE
jsignal_wgooglemap_coordinate_name(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<Wt::WGoogleMap::Coordinate> * sig = static_cast<Wt::JSignal<Wt::WGoogleMap::Coordinate> * >(o->ptr);
    return rb_str_new2(sig->name().c_str());
}

static VALUE
jsignal_wgooglemap_coordinate_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::JSignal<Wt::WGoogleMap::Coordinate> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
jsignal_wgooglemap_coordinate_emit(VALUE self, VALUE arg1)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::JSignal<Wt::WGoogleMap::Coordinate> * sig = static_cast<Wt::JSignal<Wt::WGoogleMap::Coordinate> * >(o->ptr);
    smokeruby_object * a1 = value_obj_info(arg1);
    sig->emit(*(static_cast<Wt::WGoogleMap::Coordinate *>(a1->ptr)));
    return self;
}
#endif

static VALUE
new_signal(int argc, VALUE * argv, VALUE klass)
{
    Wt::Signal<void> * sig = 0;
    if (argc == 0) {
        sig = new Wt::Signal<void>();
    } else if (argc == 1) {
        Wt::WObject * sender = Wt::Ruby::SlotInvocation::toWObject(argv[0]);
        if (sender == 0) {
            return rb_call_super(argc, argv);
        }

        sig = new Wt::Signal<void>(sender);
    } else {
        return rb_call_super(argc, argv);
    }

    smokeruby_object  * o = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::SignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::signal_class, smokeruby_mark, smokeruby_free, o);
    mapObject(result, result);
    return result;
}

static VALUE
signal_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect< Wt::Signal<void> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_emit(VALUE self)
{
    smokeruby_object * o = value_obj_info(self);
    if (o == 0 || o->ptr == 0) {
        return self;
    }

    Wt::Signal<void> * sig = static_cast<Wt::Signal<void> * >(o->ptr);
    sig->emit();
    return self;
}

static VALUE
new_signal1(int argc, VALUE * argv, VALUE klass)
{
    Wt::Signal<VALUE> * sig = 0;
    if (argc == 0) {
        sig = new Wt::Signal<VALUE>();
    } else if (argc == 1) {
        Wt::WObject * sender = Wt::Ruby::SlotInvocation::toWObject(argv[0]);
        if (sender == 0) {
            return rb_call_super(argc, argv);
        }

        sig = new Wt::Signal<VALUE>(sender);
    } else {
        return rb_call_super(argc, argv);
    }

    smokeruby_object  * o = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::SignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::signal1_class, smokeruby_mark, smokeruby_free, o);
    mapObject(result, result);
    return result;
}

static VALUE
signal1_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<VALUE> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal1_emit(VALUE self, VALUE arg)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<VALUE> * sig = static_cast<Wt::Signal<VALUE> *>(o->ptr);
    sig->emit(arg);
    return self;
}

static VALUE
new_signal2(int argc, VALUE * argv, VALUE klass)
{
    Wt::Signal<VALUE, VALUE> * sig = 0;
    if (argc == 0) {
        sig = new Wt::Signal<VALUE, VALUE>();
    } else if (argc == 1) {
        Wt::WObject * sender = Wt::Ruby::SlotInvocation::toWObject(argv[0]);
        if (sender == 0) {
            return rb_call_super(argc, argv);
        }

        sig = new Wt::Signal<VALUE, VALUE>(sender);
    } else {
        return rb_call_super(argc, argv);
    }

    smokeruby_object  * o = alloc_smokeruby_object( true, 
                                                    wt_Smoke, 
                                                    wt_Smoke->idClass("Wt::SignalBase").index, 
                                                    static_cast<void *>(sig) );

    VALUE result = Data_Wrap_Struct(Wt::Ruby::signal2_class, smokeruby_mark, smokeruby_free, o);
    mapObject(result, result);
    return result;
}

static VALUE
signal2_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<VALUE, VALUE> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal2_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<VALUE, VALUE> * sig = static_cast<Wt::Signal<VALUE, VALUE> *>(o->ptr);
    sig->emit(arg1, arg2);
    return self;
}

static VALUE
signal_boolean_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<bool> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_boolean_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<bool>, bool>(self, arg);
    return self;
}

static VALUE
signal_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_int_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<int>, int>(self, arg);
    return self;
}

static VALUE
signal_int_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<int, int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_int_int_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<int, int> * sig = static_cast<Wt::Signal<int, int> *>(o->ptr);
    sig->emit(NUM2INT(arg1), NUM2INT(arg2));
    return self;
}

static VALUE
signal_orientation_int_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect3< Wt::Signal<Wt::Orientation, int, int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_orientation_int_int_emit(VALUE self, VALUE arg1, VALUE arg2, VALUE arg3)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<Wt::Orientation, int, int> * sig = static_cast<Wt::Signal<Wt::Orientation, int, int> *>(o->ptr);
    sig->emit(static_cast<Wt::Orientation>(NUM2INT(arg1)), NUM2INT(arg2), NUM2INT(arg3));
    return self;
}

static VALUE
signal_int_int_int_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect4< Wt::Signal<int, int, int, int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_int_int_int_int_emit(VALUE self, VALUE arg1, VALUE arg2, VALUE arg3, VALUE arg4)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<int, int, int, int> * sig = static_cast<Wt::Signal<int, int, int, int> *>(o->ptr);
    sig->emit(NUM2INT(arg1), NUM2INT(arg2), NUM2INT(arg3), NUM2INT(arg4));
    return self;
}

static VALUE
signal_longlong_longlong_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<long long, long long> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_longlong_longlong_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<long long, long long> * sig = static_cast<Wt::Signal<long long, long long> *>(o->ptr);
    sig->emit(NUM2LL(arg1), NUM2LL(arg2));
    return self;
}

/* We need some sort of enum here so that the code compiles. However, the choice
 * of Wt::StandardButton is arbitrary, and the assumption is that any enum signal
 * can be cast to this standard button one.
 */
static VALUE
signal_enum_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::StandardButton> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_enum_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::StandardButton>, Wt::StandardButton>(self, arg);
    return self;
}

static VALUE
signal_wstring_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WString> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wstring_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WString>, Wt::WString>(self, arg);
    return self;
}

static VALUE
signal_string_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<std::string> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_string_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<std::string> * sig = static_cast<Wt::Signal<std::string> *>(o->ptr);
    sig->emit(std::string(StringValuePtr(arg1)));
    return self;
}

static VALUE
signal_string_string_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<std::string, std::string> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_string_string_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<std::string, std::string> * sig = static_cast<Wt::Signal<std::string, std::string> *>(o->ptr);
    sig->emit(std::string(StringValuePtr(arg1)), std::string(StringValuePtr(arg2)));
    return self;
}

static VALUE
signal_wwidget_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WWidget*> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wwidget_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WWidget*>, Wt::WWidget*>(self, arg);
    return self;
}

static VALUE
signal_wdate_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WDate> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wdate_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WDate>, Wt::WDate>(self, arg);
    return self;
}

static VALUE
signal_wmodelindex_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WModelIndex> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wmodelindex_emit(VALUE self, VALUE arg1)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WModelIndex>, Wt::WModelIndex>(self, arg1);
    return self;
}

static VALUE
signal_wmodelindex_int_int_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect3< Wt::Signal<Wt::WModelIndex,int,int> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wmodelindex_int_int_emit(VALUE self, VALUE arg1, VALUE arg2, VALUE arg3)
{
    smokeruby_object * o = value_obj_info(self);
    Wt::Signal<Wt::WModelIndex,int, int> * sig = static_cast<Wt::Signal<Wt::WModelIndex,int, int> *>(o->ptr);
    smokeruby_object * a1 = value_obj_info(arg1);
    sig->emit(*(static_cast<Wt::WModelIndex *>(a1->ptr)), NUM2INT(arg2), NUM2INT(arg3));
    return self;
}

static VALUE
signal_wmodelindex_wmodelindex_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<Wt::WModelIndex,Wt::WModelIndex> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wmodelindex_wmodelindex_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    Wt::Ruby::signal_emit2<Wt::Signal<Wt::WModelIndex,Wt::WModelIndex>, Wt::WModelIndex, Wt::WModelIndex>(self, arg1, arg2);
    return self;
}

static VALUE
signal_wmodelindex_wmouseevent_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect2< Wt::Signal<Wt::WModelIndex,Wt::WMouseEvent> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wmodelindex_wmouseevent_emit(VALUE self, VALUE arg1, VALUE arg2)
{
    Wt::Ruby::signal_emit2<Wt::Signal<Wt::WModelIndex,Wt::WMouseEvent>, Wt::WModelIndex, Wt::WMouseEvent>(self, arg1, arg2);
    return self;
}

static VALUE
signal_wmenuitem_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WMenuItem*> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wmenuitem_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WMenuItem*>, Wt::WMenuItem*>(self, arg);
    return self;
}

static VALUE
signal_wstandarditem_connect(int argc, VALUE * argv, VALUE self)
{
    if (argc == 1 && TYPE(argv[0]) == T_ARRAY) {
        Wt::Ruby::signal_connect1< Wt::Signal<Wt::WStandardItem*> >(self, argv[0]);
        return self;
    }

    return rb_call_super(argc, argv);
}

static VALUE
signal_wstandarditem_emit(VALUE self, VALUE arg)
{
    Wt::Ruby::signal_emit1<Wt::Signal<Wt::WStandardItem*>, Wt::WStandardItem*>(self, arg);
    return self;
}

void 
define_eventsignals(VALUE klass)
{
    Wt::Ruby::eventsignal_void_class = rb_define_class_under(Wt::Ruby::wt_module, "EventSignalVoid", klass);
    rb_define_method(Wt::Ruby::eventsignal_void_class, "connect", (VALUE (*) (...)) eventsignal_void_connect, -1);
    rb_define_method(Wt::Ruby::eventsignal_void_class, "emit", (VALUE (*) (...)) eventsignal_void_emit, 0);

    Wt::Ruby::eventsignal_wkey_event_class = rb_define_class_under(Wt::Ruby::wt_module, "EventSignalWKeyEvent", klass);
    rb_define_method(Wt::Ruby::eventsignal_wkey_event_class, "connect", (VALUE (*) (...)) eventsignal_wkey_event_connect, -1);
    rb_define_method(Wt::Ruby::eventsignal_wkey_event_class, "emit", (VALUE (*) (...)) eventsignal_wkey_event_emit, 1);

    Wt::Ruby::eventsignal_wmouse_event_class = rb_define_class_under(Wt::Ruby::wt_module, "EventSignalWMouseEvent", klass);
    rb_define_method(Wt::Ruby::eventsignal_wmouse_event_class, "connect", (VALUE (*) (...)) eventsignal_wmouse_event_connect, -1);
    rb_define_method(Wt::Ruby::eventsignal_wmouse_event_class, "emit", (VALUE (*) (...)) eventsignal_wmouse_event_emit, 1);

    Wt::Ruby::eventsignal_wresponse_event_class = rb_define_class_under(Wt::Ruby::wt_module, "EventSignalWResponseEvent", klass);
    rb_define_method(Wt::Ruby::eventsignal_wresponse_event_class, "connect", (VALUE (*) (...)) eventsignal_wresponse_event_connect, -1);
    rb_define_method(Wt::Ruby::eventsignal_wresponse_event_class, "emit", (VALUE (*) (...)) eventsignal_wresponse_event_emit, 1);

    Wt::Ruby::eventsignal_wscroll_event_class = rb_define_class_under(Wt::Ruby::wt_module, "EventSignalWScrollEvent", klass);
    rb_define_method(Wt::Ruby::eventsignal_wscroll_event_class, "connect", (VALUE (*) (...)) eventsignal_wscroll_event_connect, -1);
    rb_define_method(Wt::Ruby::eventsignal_wscroll_event_class, "emit", (VALUE (*) (...)) eventsignal_wscroll_event_emit, 1);

    Wt::Ruby::jsignal_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignal", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal_class, "new", (VALUE (*) (...)) new_jsignal, -1);
    rb_define_method(Wt::Ruby::jsignal_class, "connect", (VALUE (*) (...)) jsignal_connect, -1);
    rb_define_method(Wt::Ruby::jsignal_class, "emit", (VALUE (*) (...)) jsignal_emit, 0);
    rb_define_method(Wt::Ruby::jsignal_class, "name", (VALUE (*) (...)) jsignal_name, 0);

    Wt::Ruby::jsignal1_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignal1", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal1_class, "new", (VALUE (*) (...)) new_jsignal1, -1);
    rb_define_method(Wt::Ruby::jsignal1_class, "connect", (VALUE (*) (...)) jsignal1_connect, -1);
    rb_define_method(Wt::Ruby::jsignal1_class, "emit", (VALUE (*) (...)) jsignal1_emit, 1);
    rb_define_method(Wt::Ruby::jsignal1_class, "name", (VALUE (*) (...)) jsignal1_name, 0);

    Wt::Ruby::jsignal2_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignal2", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal2_class, "new", (VALUE (*) (...)) new_jsignal2, -1);
    rb_define_method(Wt::Ruby::jsignal2_class, "connect", (VALUE (*) (...)) jsignal2_connect, -1);
    rb_define_method(Wt::Ruby::jsignal2_class, "emit", (VALUE (*) (...)) jsignal2_emit, 2);
    rb_define_method(Wt::Ruby::jsignal2_class, "name", (VALUE (*) (...)) jsignal2_name, 0);

    Wt::Ruby::jsignal_boolean_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignalBoolean", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal_boolean_class, "new", (VALUE (*) (...)) new_jsignal_boolean, -1);
    rb_define_method(Wt::Ruby::jsignal_boolean_class, "connect", (VALUE (*) (...)) jsignal_boolean_connect, -1);
    rb_define_method(Wt::Ruby::jsignal_boolean_class, "emit", (VALUE (*) (...)) jsignal_boolean_emit, 1);
    rb_define_method(Wt::Ruby::jsignal_boolean_class, "name", (VALUE (*) (...)) jsignal_boolean_name, 0);

    Wt::Ruby::jsignal_int_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignalInt", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal_int_class, "new", (VALUE (*) (...)) new_jsignal_int, -1);
    rb_define_method(Wt::Ruby::jsignal_int_class, "connect", (VALUE (*) (...)) jsignal_int_connect, -1);
    rb_define_method(Wt::Ruby::jsignal_int_class, "emit", (VALUE (*) (...)) jsignal_int_emit, 1);
    rb_define_method(Wt::Ruby::jsignal_int_class, "name", (VALUE (*) (...)) jsignal_int_name, 0);

    Wt::Ruby::jsignal_int_int_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignalIntInt", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal_int_int_class, "new", (VALUE (*) (...)) new_jsignal_int_int, -1);
    rb_define_method(Wt::Ruby::jsignal_int_int_class, "connect", (VALUE (*) (...)) jsignal_int_int_connect, -1);
    rb_define_method(Wt::Ruby::jsignal_int_int_class, "emit", (VALUE (*) (...)) jsignal_int_int_emit, 2);
    rb_define_method(Wt::Ruby::jsignal_int_int_class, "name", (VALUE (*) (...)) jsignal_int_int_name, 0);

#if WT_VERSION >= 0x02990000
    Wt::Ruby::jsignal_wgooglemap_coordinate_class = rb_define_class_under(Wt::Ruby::wt_module, "JSignalIntInt", klass);
    rb_define_singleton_method(Wt::Ruby::jsignal_wgooglemap_coordinate_class, "new", (VALUE (*) (...)) new_jsignal_wgooglemap_coordinate, -1);
    rb_define_method(Wt::Ruby::jsignal_wgooglemap_coordinate_class, "connect", (VALUE (*) (...)) jsignal_wgooglemap_coordinate_connect, -1);
    rb_define_method(Wt::Ruby::jsignal_wgooglemap_coordinate_class, "emit", (VALUE (*) (...)) jsignal_wgooglemap_coordinate_emit, 2);
    rb_define_method(Wt::Ruby::jsignal_wgooglemap_coordinate_class, "name", (VALUE (*) (...)) jsignal_wgooglemap_coordinate_name, 0);
#endif
}

void
define_signals(VALUE klass)
{
    Wt::Ruby::signal_class = rb_define_class_under(Wt::Ruby::wt_module, "Signal", klass);
    rb_define_singleton_method(Wt::Ruby::signal_class, "new", (VALUE (*) (...)) new_signal, -1);
    rb_define_method(Wt::Ruby::signal_class, "connect", (VALUE (*) (...)) signal_connect, -1);
    rb_define_method(Wt::Ruby::signal_class, "emit", (VALUE (*) (...)) signal_emit, 0);

    Wt::Ruby::signal1_class = rb_define_class_under(Wt::Ruby::wt_module, "Signal1", klass);
    rb_define_singleton_method(Wt::Ruby::signal1_class, "new", (VALUE (*) (...)) new_signal1, -1);
    rb_define_method(Wt::Ruby::signal1_class, "connect", (VALUE (*) (...)) signal1_connect, -1);
    rb_define_method(Wt::Ruby::signal1_class, "emit", (VALUE (*) (...)) signal1_emit, 1);

    Wt::Ruby::signal2_class = rb_define_class_under(Wt::Ruby::wt_module, "Signal2", klass);
    rb_define_singleton_method(Wt::Ruby::signal2_class, "new", (VALUE (*) (...)) new_signal2, -1);
    rb_define_method(Wt::Ruby::signal2_class, "connect", (VALUE (*) (...)) signal2_connect, -1);
    rb_define_method(Wt::Ruby::signal2_class, "emit", (VALUE (*) (...)) signal2_emit, 2);

    Wt::Ruby::signal_boolean_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalBoolean", klass);
    rb_define_method(Wt::Ruby::signal_boolean_class, "connect", (VALUE (*) (...)) signal_boolean_connect, -1);
    rb_define_method(Wt::Ruby::signal_boolean_class, "emit", (VALUE (*) (...)) signal_boolean_emit, 1);

    Wt::Ruby::signal_int_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalInt", klass);
    rb_define_method(Wt::Ruby::signal_int_class, "connect", (VALUE (*) (...)) signal_int_connect, -1);
    rb_define_method(Wt::Ruby::signal_int_class, "emit", (VALUE (*) (...)) signal_int_emit, 1);

    Wt::Ruby::signal_int_int_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalIntInt", klass);
    rb_define_method(Wt::Ruby::signal_int_int_class, "connect", (VALUE (*) (...)) signal_int_int_connect, -1);
    rb_define_method(Wt::Ruby::signal_int_int_class, "emit", (VALUE (*) (...)) signal_int_int_emit, 1);

    Wt::Ruby::signal_orientation_int_int_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalOrientationIntInt", klass);
    rb_define_method(Wt::Ruby::signal_orientation_int_int_class, "connect", (VALUE (*) (...)) signal_orientation_int_int_connect, -1);
    rb_define_method(Wt::Ruby::signal_orientation_int_int_class, "emit", (VALUE (*) (...)) signal_orientation_int_int_emit, 1);

    Wt::Ruby::signal_int_int_int_int_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalIntIntIntInt", klass);
    rb_define_method(Wt::Ruby::signal_int_int_int_int_class, "connect", (VALUE (*) (...)) signal_int_int_int_int_connect, -1);
    rb_define_method(Wt::Ruby::signal_int_int_int_int_class, "emit", (VALUE (*) (...)) signal_int_int_int_int_emit, 1);

    Wt::Ruby::signal_longlong_longlong_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalLonglongLonglong", klass);
    rb_define_method(Wt::Ruby::signal_longlong_longlong_class, "connect", (VALUE (*) (...)) signal_longlong_longlong_connect, -1);
    rb_define_method(Wt::Ruby::signal_longlong_longlong_class, "emit", (VALUE (*) (...)) signal_longlong_longlong_emit, 1);

    Wt::Ruby::signal_enum_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalEnum", klass);
    rb_define_method(Wt::Ruby::signal_enum_class, "connect", (VALUE (*) (...)) signal_enum_connect, -1);
    rb_define_method(Wt::Ruby::signal_enum_class, "emit", (VALUE (*) (...)) signal_enum_emit, 1);

    Wt::Ruby::signal_wstring_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWString", klass);
    rb_define_method(Wt::Ruby::signal_wstring_class, "connect", (VALUE (*) (...)) signal_wstring_connect, -1);
    rb_define_method(Wt::Ruby::signal_wstring_class, "emit", (VALUE (*) (...)) signal_wstring_emit, 1);

    Wt::Ruby::signal_string_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalString", klass);
    rb_define_method(Wt::Ruby::signal_string_class, "connect", (VALUE (*) (...)) signal_string_connect, -1);
    rb_define_method(Wt::Ruby::signal_string_class, "emit", (VALUE (*) (...)) signal_string_emit, 1);

    Wt::Ruby::signal_string_string_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalStringString", klass);
    rb_define_method(Wt::Ruby::signal_string_string_class, "connect", (VALUE (*) (...)) signal_string_string_connect, -1);
    rb_define_method(Wt::Ruby::signal_string_string_class, "emit", (VALUE (*) (...)) signal_string_string_emit, 1);

    Wt::Ruby::signal_wwidget_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWWidget", klass);
    rb_define_method(Wt::Ruby::signal_wwidget_class, "connect", (VALUE (*) (...)) signal_wwidget_connect, -1);
    rb_define_method(Wt::Ruby::signal_wwidget_class, "emit", (VALUE (*) (...)) signal_wwidget_emit, 1);

    Wt::Ruby::signal_wdate_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWDate", klass);
    rb_define_method(Wt::Ruby::signal_wdate_class, "connect", (VALUE (*) (...)) signal_wdate_connect, -1);
    rb_define_method(Wt::Ruby::signal_wdate_class, "emit", (VALUE (*) (...)) signal_wdate_emit, 1);

    Wt::Ruby::signal_wmodelindex_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWModelIndex", klass);
    rb_define_method(Wt::Ruby::signal_wmodelindex_class, "connect", (VALUE (*) (...)) signal_wmodelindex_connect, -1);
    rb_define_method(Wt::Ruby::signal_wmodelindex_class, "emit", (VALUE (*) (...)) signal_wmodelindex_emit, 1);

    Wt::Ruby::signal_wmodelindex_int_int_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWModelIndex", klass);
    rb_define_method(Wt::Ruby::signal_wmodelindex_int_int_class, "connect", (VALUE (*) (...)) signal_wmodelindex_int_int_connect, -1);
    rb_define_method(Wt::Ruby::signal_wmodelindex_int_int_class, "emit", (VALUE (*) (...)) signal_wmodelindex_int_int_emit, 3);

    Wt::Ruby::signal_wmodelindex_wmodelindex_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWModelIndexWModelIndex", klass);
    rb_define_method(Wt::Ruby::signal_wmodelindex_wmodelindex_class, "connect", (VALUE (*) (...)) signal_wmodelindex_wmodelindex_connect, -1);
    rb_define_method(Wt::Ruby::signal_wmodelindex_wmodelindex_class, "emit", (VALUE (*) (...)) signal_wmodelindex_wmodelindex_emit, 2);

    Wt::Ruby::signal_wmodelindex_wmouseevent_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWModelIndexWMouseEvent", klass);
    rb_define_method(Wt::Ruby::signal_wmodelindex_wmouseevent_class, "connect", (VALUE (*) (...)) signal_wmodelindex_wmouseevent_connect, -1);
    rb_define_method(Wt::Ruby::signal_wmodelindex_wmouseevent_class, "emit", (VALUE (*) (...)) signal_wmodelindex_wmouseevent_emit, 2);

    Wt::Ruby::signal_wmenuitem_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWWidget", klass);
    rb_define_method(Wt::Ruby::signal_wmenuitem_class, "connect", (VALUE (*) (...)) signal_wmenuitem_connect, -1);
    rb_define_method(Wt::Ruby::signal_wmenuitem_class, "emit", (VALUE (*) (...)) signal_wmenuitem_emit, 1);

    Wt::Ruby::signal_wstandarditem_class = rb_define_class_under(Wt::Ruby::wt_module, "SignalWStandardItem", klass);
    rb_define_method(Wt::Ruby::signal_wstandarditem_class, "connect", (VALUE (*) (...)) signal_wstandarditem_connect, -1);
    rb_define_method(Wt::Ruby::signal_wstandarditem_class, "emit", (VALUE (*) (...)) signal_wstandarditem_emit, 1);
}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
