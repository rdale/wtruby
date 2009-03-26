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

#include <smoke/smoke.h>

#include <ruby.h>

#include <Wt/Chart/WDataSeries>
#include <Wt/WAbstractArea>
#include <Wt/WDate>
#include <Wt/WFormWidget>
#include <Wt/WLabel>
#include <Wt/WLineF>
#include <Wt/WLogger>
#include <Wt/WMenu>
#include <Wt/WMenuItem>
#include <Wt/WSubMenuItem>
#include <Wt/WModelIndex>
#include <Wt/WObject>
#include <Wt/WPainterPath>
#include <Wt/WPoint>
#include <Wt/WPointF>
#include <Wt/WRadioButton>
#include <Wt/WRectF>
#include <Wt/WSignal>
#include <Wt/WStandardItem>
#include <Wt/WString>
#include <Wt/WTable>
#include <Wt/WTreeNode>
#include <Wt/WWidget>

#if WT_VERSION >= 0x0299000000
#include <Wt/WGoogleMap>
#endif

#include <Wt/Chart/WDataSeries>
#include <Wt/Chart/WCartesianChart>

#include "marshall.h"
#include "wtruby.h"
#include "smokeruby.h"
#include "marshall_basetypes.h"
#include "marshall_macros.h"

namespace Wt {
  namespace Ruby {
VALUE eventsignal_void_class = Qnil;
VALUE eventsignal_wkey_event_class = Qnil;
VALUE eventsignal_wmouse_event_class = Qnil;
VALUE eventsignal_wresponse_event_class = Qnil;
VALUE eventsignal_wscroll_event_class = Qnil;

VALUE jsignal_class = Qnil;
VALUE jsignal1_class = Qnil;
VALUE jsignal2_class = Qnil;
VALUE jsignal_boolean_class = Qnil;
VALUE jsignal_int_class = Qnil;
VALUE jsignal_int_int_class = Qnil;

#if WT_VERSION >= 0x02990000
VALUE jsignal_wgooglemap_coordinate_class = Qnil;
#endif

VALUE signal_class = Qnil;
VALUE signal1_class = Qnil;
VALUE signal2_class = Qnil;
VALUE signal_boolean_class = Qnil;
VALUE signal_int_class = Qnil;
VALUE signal_int_int_class = Qnil;
VALUE signal_int_int_int_int_class = Qnil;
VALUE signal_orientation_int_int_class = Qnil;
VALUE signal_longlong_longlong_class = Qnil;
VALUE signal_enum_class = Qnil;
VALUE signal_wdate_class = Qnil;
VALUE signal_wmenuitem_class = Qnil;
VALUE signal_wwidget_class = Qnil;
VALUE signal_wmodelindex_class = Qnil;
VALUE signal_wmodelindex_int_int_class = Qnil;
VALUE signal_wmodelindex_wmodelindex_class = Qnil;
VALUE signal_wmodelindex_wmouseevent_class = Qnil;
VALUE signal_wstandarditem_class = Qnil;
VALUE signal_wstring_class = Qnil;
VALUE signal_string_class = Qnil;
VALUE signal_string_string_class = Qnil;

VALUE wt_std_ostream_class = Qnil;

static bool
matches_arg(Smoke *smoke, Smoke::Index meth, Smoke::Index argidx, const char *argtype)
{
    Smoke::Index *arg = smoke->argumentList + smoke->methods[meth].args + argidx;
    SmokeType type = SmokeType(smoke, *arg);
    if (type.name() != 0 && std::strcmp(type.name(), argtype) == 0) {
        return true;
    }
    return false;
}

void *
construct_copy(smokeruby_object *o)
{
    const char * className = o->smoke->className(o->classId);
    int classNameLen = strlen(className);
    char * ccSig = new char[classNameLen + 2];       // copy constructor signature

    std::string fullClassName(className);
    std::size_t p1 = fullClassName.find("::", 0);
    std::size_t p2 = 0;
    while (p1 != std::string::npos) {
        p2 = p1 + strlen("::");
        p1 = fullClassName.find("::", p2);
    }

    strcpy(ccSig, fullClassName.substr(p2, fullClassName.size() - p2).c_str());
    strcat(ccSig, "#");

    Smoke::ModuleIndex ccId = o->smoke->findMethodName(className, ccSig);
    delete[] ccSig;

    char * ccArg = new char[classNameLen + 8];
    sprintf(ccArg, "const %s&", className);

    Smoke::ModuleIndex classIdx = { o->smoke, o->classId };
    Smoke::ModuleIndex ccMeth = o->smoke->findMethod(classIdx, ccId);

    if (ccMeth.index == 0) {
        delete[] ccArg;
        if (Wt::Ruby::do_debug & wtdb_gc) {
            printf("WARNING: construct_copy() failed %s\n", className);
        }
        return 0;
    }
    Smoke::Index method = ccMeth.smoke->methodMaps[ccMeth.index].method;
    if (method > 0) {
        // Make sure it's a copy constructor
        if (!matches_arg(o->smoke, method, 0, ccArg)) {
            delete[] ccArg;
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("WARNING: construct_copy() failed %s\n", className);
            }
            return 0;
        }
        delete[] ccArg;
        ccMeth.index = method;
    } else {
        // ambiguous method, pick the copy constructor
        Smoke::Index i = -method;
        while(ccMeth.smoke->ambiguousMethodList[i]) {
            if (matches_arg(ccMeth.smoke, ccMeth.smoke->ambiguousMethodList[i], 0, ccArg)) {
                break;
            }
            i++;
        }
        delete[] ccArg;
        ccMeth.index = ccMeth.smoke->ambiguousMethodList[i];
        if (ccMeth.index == 0) {
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("WARNING: construct_copy() failed %s\n", className);
            }
            return 0;
        }
    }

    // Okay, ccMeth is the copy constructor. Time to call it.
    Smoke::StackItem args[2];
    args[0].s_voidp = 0;
    args[1].s_voidp = o->ptr;
    Smoke::ClassFn fn = o->smoke->classes[o->classId].classFn;
    (*fn)(o->smoke->methods[ccMeth.index].method, 0, args);

    // Initialize the binding for the new instance
    Smoke::StackItem s[2];
    s[1].s_voidp = Wt::Ruby::modules[o->smoke].binding;
    (*fn)(0, args[0].s_voidp, s);

    return args[0].s_voidp;

}
  }
}

static void
mark_wobject_children(Wt::WObject * wobject)
{
    const std::vector<Wt::WObject*>& l = wobject->children();
    
    for (unsigned int i = 0; i < l.size(); i++) {
        Wt::WObject * child = l.at(i);
        VALUE obj = getPointerObject(child);
        if (obj != Qnil) {
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), child, (void*)obj);
            }
            rb_gc_mark(obj);
        }
        
        mark_wobject_children(child);
    }
}

static void
mark_wwebwidget_children(Wt::WWebWidget * widget)
{
    const std::vector<Wt::WWidget*>& l = widget->children();
    
    for (unsigned int i = 0; i < l.size(); i++) {
        Wt::WWidget * child = l.at(i);
        VALUE obj = getPointerObject(child);
        if (obj != Qnil) {
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), child, (void*)obj);
            }
            rb_gc_mark(obj);
        }
    }
}

static void
mark_wcontainerwidget_children(Wt::WContainerWidget * widget)
{
    VALUE obj;
    
    const std::vector<Wt::WWidget*> & l = widget->children();

    for (unsigned int i = 0; i < l.size(); i++) {
        Wt::WWidget * child = l.at(i);
        obj = getPointerObject(child);
        if (obj != Qnil) {
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), child, (void*)obj);
            }
            rb_gc_mark(obj);
        }
    }
}

static void
mark_wmenu_items(Wt::WMenu * menu)
{
    VALUE obj;
    
    const std::vector<Wt::WMenuItem*> & l = menu->items();

    for (unsigned int i = 0; i < l.size(); i++) {
        Wt::WMenuItem * item = l.at(i);
        obj = getPointerObject(item);
        if (obj != Qnil) {
            if (Wt::Ruby::do_debug & wtdb_gc) {
                printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), item, (void*)obj);
            }
            rb_gc_mark(obj);

            if (std::strcmp(rb_obj_classname(obj), "Wt::WSubMenuItem") == 0) {
                Wt::WMenu * subMenu = static_cast<Wt::WSubMenuItem*>(item)->subMenu();
                obj = getPointerObject(subMenu);
                if (obj != Qnil) {
                    if (Wt::Ruby::do_debug & wtdb_gc) {
                        printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), subMenu, (void*)obj);
                    }
                    rb_gc_mark(obj);
                }
                mark_wmenu_items(subMenu);
            }
        }
    }
}

void
smokeruby_mark(void * p)
{
    VALUE obj;
    smokeruby_object * o = (smokeruby_object *) p;
    const char * className = o->smoke->classes[o->classId].className;
    
    if (Wt::Ruby::do_debug & wtdb_gc) printf("Checking for mark (%s*)%p\n", className, o->ptr);

    if (o->ptr && o->allocated) {
        if (o->smoke->isDerivedFromByName(className, "Wt::WObject")) {
            Wt::WObject * wobject = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);
            mark_wobject_children(wobject);
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::WWebWidget")) {
            Wt::WWebWidget * widget = (Wt::WWebWidget *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WWebWidget").index);
            mark_wwebwidget_children(widget);
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::WMenu")) {
            Wt::WMenu * menu = (Wt::WMenu *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WMenu").index);
            mark_wmenu_items(menu);
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::WContainerWidget")) {
            Wt::WContainerWidget * widget = (Wt::WContainerWidget *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WContainerWidget").index);
            mark_wcontainerwidget_children(widget);

            Wt::WLayout * layout = widget->layout();
            obj = getPointerObject(layout);
            if (obj != Qnil) {
                if (Wt::Ruby::do_debug & wtdb_gc) {
                    printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), layout, (void*) obj);
                }
                rb_gc_mark(obj);
            }
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::WFormWidget")) {
            Wt::WFormWidget * widget = (Wt::WFormWidget *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WFormWidget").index);

            Wt::WLabel * label = widget->label();
            obj = getPointerObject(label);
            if (obj != Qnil) {
                if (Wt::Ruby::do_debug & wtdb_gc) {
                    printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), label, (void*) obj);
                }
                rb_gc_mark(obj);
            }

            Wt::WValidator * validator = widget->validator();
            obj = getPointerObject(label);
            if (obj != Qnil) {
                if (Wt::Ruby::do_debug & wtdb_gc) {
                    printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), validator, (void*) obj);
                }
                rb_gc_mark(obj);
            }
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::Chart::WCartesianChart")) {
            Wt::Chart::WCartesianChart * chart = (Wt::Chart::WCartesianChart *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::Chart::WCartesianChart").index);
            const std::vector<Wt::Chart::WDataSeries> & l = chart->series();

            for (unsigned int i = 0; i < l.size(); i++) {
                obj = getPointerObject((void *) &(l.at(i)));
                if (obj != Qnil) {
                    if (Wt::Ruby::do_debug & wtdb_gc) {
                        printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), &(l.at(i)), (void*)obj);
                    }
                    rb_gc_mark(obj);
                }
            }
        }

        if (o->smoke->isDerivedFromByName(className, "Wt::WTable")) {
            Wt::WTable * table = (Wt::WTable *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WTable").index);
            for (unsigned int row = 0; row < table->rowCount(); row++) {
                Wt::WTableRow * tableRow = table->rowAt(row);
                obj = getPointerObject(tableRow);
                if (obj != Qnil) {
                    if (Wt::Ruby::do_debug & wtdb_gc) {
                        printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), tableRow, (void*)obj);
                    }
                    rb_gc_mark(obj);
                }
                for (unsigned int column; column < table->columnCount(); column++) {
                    Wt::WTableCell * cell = table->elementAt(row, column);
                    obj = getPointerObject(cell);
                    if (obj != Qnil) {
                        if (Wt::Ruby::do_debug & wtdb_gc) {
                            printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), cell, (void*)obj);
                        }
                        rb_gc_mark(obj);
                    }
                }
            }

            for (unsigned int column; column < table->columnCount(); column++) {
                Wt::WTableColumn * tableColumn = table->columnAt(column);
                obj = getPointerObject(tableColumn);
                if (obj != Qnil) {
                    if (Wt::Ruby::do_debug & wtdb_gc) {
                        printf("Marking (%s*)%p -> %p\n", rb_obj_classname(obj), tableColumn, (void*)obj);
                    }
                    rb_gc_mark(obj);
                }
            }
        }
    }
}

void
smokeruby_free(void * p)
{
    smokeruby_object *o = (smokeruby_object*)p;
    const char *className = o->smoke->classes[o->classId].className;
    
    if (Wt::Ruby::do_debug & wtdb_gc) {
        printf("Checking for delete (%s*)%p allocated: %s\n", className, o->ptr, o->allocated ? "true" : "false");
    }
    
    if (Wt::Ruby::application_terminated || !o->allocated || o->ptr == 0) {
        free_smokeruby_object(o);
        return;
    }
    
    unmapPointer(o, o->classId, 0);
    Wt::Ruby::object_count --;

    if (o->smoke->isDerivedFromByName(className, "Wt::WObject")) {
        Wt::WObject * object = (Wt::WObject *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WObject").index);
        if (object->parent() != 0) {
            free_smokeruby_object(o);
            return;
        }
    }

    if (o->smoke->isDerivedFromByName(className, "Wt::WMenuItem")) {
        Wt::WMenuItem * item = (Wt::WMenuItem *) o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("Wt::WMenuItem").index);
        if (item->menu() != 0) {
            free_smokeruby_object(o);
            return;
        }
    }
            
    if (Wt::Ruby::do_debug & wtdb_gc) {
        printf("Deleting (%s*)%p\n", className, o->ptr);
    }

    char *methodName = new char[strlen(className) + 2];
    methodName[0] = '~';
    strcpy(methodName + 1, className);
    Smoke::ModuleIndex nameId = o->smoke->findMethodName(className, methodName);
    Smoke::ModuleIndex classIdx = { o->smoke, o->classId };
    Smoke::ModuleIndex meth = o->smoke->findMethod(classIdx, nameId);
    if (meth.index > 0) {
        Smoke::Method &m = meth.smoke->methods[meth.smoke->methodMaps[meth.index].method];
        Smoke::ClassFn fn = meth.smoke->classes[m.classId].classFn;
        Smoke::StackItem i[1];
        (*fn)(m.method, o->ptr, i);
    }
    delete[] methodName;
    free_smokeruby_object(o);
    
    return;
}

/*
 * Given an approximate classname and a wt instance, try to improve the resolution of the name
 * by using the various Wt rtti mechanisms
 */
WTRUBY_EXPORT const char *
resolve_classname_wt(smokeruby_object * o)
{
    return Wt::Ruby::modules[o->smoke].binding->className(o->classId);
}

template <class T>
static void marshall_it(Marshall *m)
{
    switch(m->action()) {
    case Marshall::FromVALUE:
        marshall_from_ruby<T>(m);
        break;

    case Marshall::ToVALUE:
        marshall_to_ruby<T>( m );
        break;
            
    default:
        m->unsupported();
        break;
    }
}

void
marshall_basetype(Marshall *m)
{
    switch(m->type().elem()) {
    case Smoke::t_bool:
        marshall_it<bool>(m);
        break;

    case Smoke::t_char:
        marshall_it<signed char>(m);
        break;
    
    case Smoke::t_uchar:
        marshall_it<unsigned char>(m);
        break;

    case Smoke::t_short:
        marshall_it<short>(m);
        break;
    
    case Smoke::t_ushort:
        marshall_it<unsigned short>(m);
        break;

    case Smoke::t_int:
        marshall_it<int>(m);
        break;
    
    case Smoke::t_uint:
        marshall_it<unsigned int>(m);
        break;

    case Smoke::t_long:
        marshall_it<long>(m);
        break;

    case Smoke::t_ulong:
        marshall_it<unsigned long>(m);
        break;

    case Smoke::t_float:
        marshall_it<float>(m);
        break;

    case Smoke::t_double:
        marshall_it<double>(m);
        break;

    case Smoke::t_enum:
        marshall_it<SmokeEnumWrapper>(m);
        break;
    
    case Smoke::t_class:
        marshall_it<SmokeClassWrapper>(m);
        break;

    default:
        m->unsupported();
        break;    
    }

}

static void marshall_void(Marshall * /*m*/) {}
static void marshall_unknown(Marshall *m) {
    m->unsupported();
}

void marshall_ucharP(Marshall *m) {
    marshall_it<unsigned char *>(m);
}

static void marshall_doubleR(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE rv = *(m->var());
        double * d = new double;
        *d = NUM2DBL(rv);
        m->item().s_voidp = d;
        m->next();
        if (m->cleanup() && m->type().isConst()) {
            delete d;
        } else {
            m->item().s_voidp = new double((double)NUM2DBL(rv));
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        double *dp = (double*)m->item().s_voidp;
        VALUE rv = *(m->var());
        if (dp == 0) {
            rv = Qnil;
            break;
        }
        *(m->var()) = rb_float_new(*dp);
        m->next();
        if (!m->type().isConst()) {
            *dp = NUM2DBL(*(m->var()));
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

static void marshall_WString(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        Wt::WString* s = 0;
        if( *(m->var()) != Qnil) {
            Wt::WString str = Wt::WString::fromUTF8(StringValuePtr(*(m->var())));
            s = new Wt::WString(str);
        } else {
            s = new Wt::WString();
        }

        m->item().s_voidp = s;
        m->next();
    /*
        if (!m->type().isConst() && *(m->var()) != Qnil && s != 0 && !s->isNull()) {
            rb_str_resize(*(m->var()), 0);
            VALUE temp = rstringFromQString(s);
            rb_str_cat2(*(m->var()), StringValuePtr(temp));
        }
    */
        if (s != 0 && m->cleanup()) {
            delete s;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        Wt::WString *s = (Wt::WString*)m->item().s_voidp;
        if (s != 0) {
            *(m->var()) = rb_str_new2(s->toUTF8().c_str());
            if (m->cleanup() || m->type().isStack() ) {
                delete s;
            }
        } else {
            *(m->var()) = Qnil;
        }
    }
    break;

    default:
        m->unsupported();
        break;
   }
}

static void marshall_StdString(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        std::string * s = 0;
        if( *(m->var()) != Qnil) {
            s = new std::string(StringValuePtr(*(m->var())));
        } else {
            s = new std::string();
        }

        m->item().s_voidp = s;
        m->next();
    /*
        if (!m->type().isConst() && *(m->var()) != Qnil && s != 0 && !s->isNull()) {
            rb_str_resize(*(m->var()), 0);
            VALUE temp = rstringFromQString(s);
            rb_str_cat2(*(m->var()), StringValuePtr(temp));
        }
    */
        if (s != 0 && m->cleanup()) {
            delete s;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        std::string *s = (std::string *) m->item().s_voidp;
        if (s != 0) {
            *(m->var()) = rb_str_new2(s->c_str());
            if (m->cleanup() || m->type().isStack() ) {
                delete s;
            }
        } else {
            *(m->var()) = Qnil;
        }
    }
    break;
 
    default:
        m->unsupported();
        break;
   }
}

static void marshall_StdCharVector(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        std::vector<char> * s = new std::vector<char>();
        if( *(m->var()) != Qnil) {
            VALUE str = *(m->var());
            s->insert(s->end(), RSTRING_PTR(str), RSTRING_PTR(str) + RSTRING_LEN(str));
        }

        m->item().s_voidp = s;
        m->next();
    /*
        if (!m->type().isConst() && *(m->var()) != Qnil && s != 0 && !s->isNull()) {
            rb_str_resize(*(m->var()), 0);
            VALUE temp = rstringFromQString(s);
            rb_str_cat2(*(m->var()), StringValuePtr(temp));
        }
    */
        if (s != 0 && m->cleanup()) {
            delete s;
        }
    }
    break;


    case Marshall::ToVALUE:
    {
/*
        std::vector<char> *s = (std::vector<char> *) m->item().s_voidp;
        if (s != 0) {
            *(m->var()) = rb_str_new2(s->c_str());
            if (m->cleanup() || m->type().isStack() ) {
                delete s;
            }
        } else {
            *(m->var()) = Qnil;
        }
*/
    }
    break;
 
    default:
        m->unsupported();
        break;
   }
}

static void marshall_StdWString(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        std::wstring * s = 0;
        if (*(m->var()) == Qnil) {
            s = new std::wstring();
        } else {
            Wt::WString s1(StringValuePtr(*(m->var())));
            std::wstring s2 = s1.value();
            s = new std::wstring(s2);
        }

        m->item().s_voidp = s;
        m->next();
    /*
        if (!m->type().isConst() && *(m->var()) != Qnil && s != 0 && !s->isNull()) {
            rb_str_resize(*(m->var()), 0);
            VALUE temp = rstringFromQString(s);
            rb_str_cat2(*(m->var()), StringValuePtr(temp));
        }
    */
        if (s != 0 && m->cleanup()) {
            delete s;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        std::wstring *s = (std::wstring *) m->item().s_voidp;
        if (s == 0) {
            *(m->var()) = Qnil;
        } else {
            Wt::WString s1(*s);
            *(m->var()) = rb_str_new2(s1.toUTF8().c_str());
            if (m->cleanup() || m->type().isStack() ) {
                delete s;
            }
        }
    }
    break;
 
    default:
        m->unsupported();
        break;
   }
}

void marshall_StdStringVector(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE: 
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        std::vector<std::string> *stringlist = new std::vector<std::string>;

        for (long i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            if (TYPE(item) != T_STRING) {
                stringlist->push_back(std::string());
                continue;
            }
            stringlist->push_back(*(new std::string(StringValuePtr(item))));
        }

        m->item().s_voidp = stringlist;
        m->next();

        if (stringlist != 0 && !m->type().isConst()) {
            rb_ary_clear(list);
            for (unsigned i = 0; i < stringlist->size(); ++i) {
                rb_ary_push(list, rb_str_new2(stringlist->at(i).c_str()));
            }
        }
        
        if (m->cleanup()) {
            delete stringlist;
        }
    
        break;
    }

    case Marshall::ToVALUE: 
    {
        std::vector<std::string> *stringlist = static_cast<std::vector<std::string> *>(m->item().s_voidp);
        if (stringlist == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();
        for (unsigned i = 0; i < stringlist->size(); ++i) {
            rb_ary_push(av, rb_str_new2(stringlist->at(i).c_str()));
        }

        *(m->var()) = av;

        if (m->cleanup()) {
            delete stringlist;
        }

    }
    break;

    default:
        m->unsupported();
        break;
    }
}


void marshall_StdIntSet(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE: 
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        std::set<int> *intlist = new std::set<int>;

        for (long i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            if (TYPE(item) != T_FIXNUM) {
                continue;
            }
            intlist->insert(NUM2INT(item));
        }

        m->item().s_voidp = intlist;
        m->next();

        if (intlist != 0 && !m->type().isConst()) {
            rb_ary_clear(list);
            for (std::set<int>::iterator at = intlist->begin(); at != intlist->end(); ++at) {
                rb_ary_push(list, INT2NUM(*at));
            }
        }
        
        if (m->cleanup()) {
            delete intlist;
        }
    
        break;
    }

    case Marshall::ToVALUE: 
    {
        std::set<int> *intlist = static_cast<std::set<int> *>(m->item().s_voidp);
        if (intlist == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();
        for (std::set<int>::iterator at = intlist->begin(); at != intlist->end(); ++at) {
            rb_ary_push(av, INT2NUM(*at));
        }

        *(m->var()) = av;

        if (m->cleanup()) {
            delete intlist;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_WStringVector(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE: 
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        std::vector<Wt::WString> *stringlist = new std::vector<Wt::WString>;

        for (long i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            if (TYPE(item) != T_STRING) {
                stringlist->push_back(Wt::WString());
                continue;
            }

            Wt::WString str = Wt::WString::fromUTF8(StringValuePtr(item));
            stringlist->push_back(str);
        }

        m->item().s_voidp = stringlist;
        m->next();

        if (stringlist != 0 && !m->type().isConst()) {
            rb_ary_clear(list);
            for (unsigned i = 0; i < stringlist->size(); ++i) {
                rb_ary_push(list, rb_str_new2(stringlist->at(i).toUTF8().c_str()));
            }
        }
        
        if (m->cleanup()) {
            delete stringlist;
        }
    
        break;
    }

    case Marshall::ToVALUE: 
    {
        std::vector<Wt::WString> *stringlist = static_cast<std::vector<Wt::WString> *>(m->item().s_voidp);
        if (stringlist == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();
        for (unsigned i = 0; i < stringlist->size(); ++i) {
            rb_ary_push(av, rb_str_new2(stringlist->at(i).toUTF8().c_str()));
        }

        *(m->var()) = av;

        if (m->cleanup()) {
            delete stringlist;
        }

    }
    break;

    default:
        m->unsupported();
        break;
    }
}

static void marshall_charP_array(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE arglist = *(m->var());
        if (    arglist == Qnil
                || TYPE(arglist) != T_ARRAY
                || RARRAY_LEN(arglist) == 0 )
        {
            m->item().s_voidp = 0;
            break;
        }

        char ** argv = new char *[RARRAY_LEN(arglist) + 1];
        long i;
        for (i = 0; i < RARRAY_LEN(arglist); i++) {
            VALUE item = rb_ary_entry(arglist, i);
            char * s = StringValuePtr(item);
            argv[i] = new char[strlen(s) + 1];
            strcpy(argv[i], s);
        }
        argv[i] = 0;
        m->item().s_voidp = argv;
        m->next();

        rb_ary_clear(arglist);
        for (i = 0; argv[i]; i++) {
            rb_ary_push(arglist, rb_str_new2(argv[i]));
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}


void marshall_voidP(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE rv = *(m->var());
        if (rv != Qnil) {
            m->item().s_voidp = (void*)NUM2INT(*(m->var()));
        } else {
            m->item().s_voidp = 0;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        *(m->var()) = Data_Wrap_Struct(rb_cObject, 0, 0, m->item().s_voidp);
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_voidP_array(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE rv = *(m->var());
        if (rv != Qnil) {
            Data_Get_Struct(rv, void*, m->item().s_voidp);
        } else {
            m->item().s_voidp = 0;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        VALUE rv = Data_Wrap_Struct(rb_cObject, 0, 0, m->item().s_voidp);
        *(m->var()) = rv;
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

/* 
   In WWidget, various enums in Wt::, such as Wt::Side, are typedef'd 
   as static consts, which aren't marshalled by default at present, 
   so special case them.
*/
void marshall_StaticConstEnum(Marshall *m) {
    switch(m->action()) {

    case Marshall::ToVALUE:
    {
        void * ptr = m->item().s_voidp;
        if (ptr == 0) {
            *(m->var()) = Qnil;
        }
        *(m->var()) = INT2NUM(*((long *) ptr));
        // There is no way to use '(enum *)' or similar here, so pick a
        // random enum, and assume they can all be deleted the same way
        delete static_cast<Wt::Side *>(ptr);
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_StdOStream(Marshall *m) {
    switch(m->action()) {

    case Marshall::FromVALUE:
    {
        m->unsupported();
    }
    break;

    case Marshall::ToVALUE:
    {
        void * ptr = m->item().s_voidp;
        if (ptr == 0) {
            *(m->var()) = Qnil;
        } else {
            *(m->var()) = Data_Wrap_Struct(Wt::Ruby::wt_std_ostream_class, 0, 0, ptr);
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_WResourceArgumentMap(Marshall *m) {
    switch(m->action()) {

    case Marshall::FromVALUE:
    {
        VALUE hash = *(m->var());
        if (TYPE(hash) != T_HASH) {
            m->item().s_voidp = 0;
            break;
        }
        
        std::map<std::string, std::vector<std::string> > * map = new std::map<std::string, std::vector<std::string> >;
        
        // Convert the ruby hash to an array of key/value arrays
        VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

        for (long i = 0; i < RARRAY_LEN(temp); i++) {
            VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
            VALUE av = rb_ary_entry(rb_ary_entry(temp, i), 1);

            std::vector<std::string> list;

            for (long j = 0; j < RARRAY_LEN(av); j++) {
                VALUE sv = rb_ary_entry(av, j);
                list.push_back(std::string(StringValuePtr(sv)));
            }

            (*map)[std::string(StringValuePtr(key))] = list;
        }
        
        m->item().s_voidp = map;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        std::map<std::string, std::vector<std::string> > *map = static_cast<std::map<std::string, std::vector<std::string> > *>(m->item().s_voidp);
        if (map == 0) {
            *(m->var()) = Qnil;
            break;
        }
        
        VALUE hv = rb_hash_new();

        for (   std::map<std::string, std::vector<std::string> >::const_iterator i = map->begin();
                i != map->end(); 
                i++ )
        {
            VALUE av = rb_ary_new();
            for (   std::vector<std::string>::const_iterator j = i->second.begin();
                    j != i->second.end();
                    j++ )
            {
                VALUE rv = rb_str_new2((*j).c_str());
                rb_ary_push(av, rv);
            }

            VALUE key = rb_str_new2(i->first.c_str());
            rb_hash_aset(hv, key, av);
        }
        
        *(m->var()) = hv;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_IntBoostAnyMap(Marshall *m) {
    switch(m->action()) {

    case Marshall::FromVALUE:
    {
        VALUE hash = *(m->var());
        if (TYPE(hash) != T_HASH) {
            m->item().s_voidp = 0;
            break;
        }
        
        std::map<int,boost::any> * map = new std::map<int,boost::any>;
        
        // Convert the ruby hash to an array of key/value arrays
        VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

        for (long i = 0; i < RARRAY_LEN(temp); i++) {
            VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
            if (std::strcmp(rb_obj_classname(key), "Wt::Enum") == 0) {
                key = rb_funcall(key, rb_intern("to_i"), 0);
            }

            VALUE any = rb_ary_entry(rb_ary_entry(temp, i), 1);
            smokeruby_object *a = value_obj_info(any);
            if (a == 0 || a->ptr == 0) {
                continue;
            }

            (*map)[NUM2INT(key)] = *((boost::any*) a->ptr);
        }
        
        m->item().s_voidp = map;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        std::map<int,boost::any> *map = static_cast<std::map<int,boost::any> *>(m->item().s_voidp);
        if (map == 0) {
            *(m->var()) = Qnil;
            break;
        }
        
        VALUE hv = rb_hash_new();

        for (   std::map<int,boost::any>::const_iterator i = map->begin();
                i != map->end(); 
                ++i )
        {
            void * ptr = (void *) &(i->second);
            VALUE obj = getPointerObject(ptr);
            if (obj == Qnil) {
                smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                                m->smoke(), 
                                                                m->smoke()->idClass("Boost::Any").index, 
                                                                ptr );
                obj = set_obj_info("Boost::Any", o);
            }
            
            rb_hash_aset(hv, INT2NUM(i->first), obj);
        }
        
        *(m->var()) = hv;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

void marshall_StringStringMap(Marshall *m) {
    switch(m->action()) {

    case Marshall::FromVALUE:
    {
        VALUE hash = *(m->var());
        if (TYPE(hash) != T_HASH) {
            m->item().s_voidp = 0;
            break;
        }
        
        std::map<std::string,std::string> * map = new std::map<std::string,std::string>;
        
        // Convert the ruby hash to an array of key/value arrays
        VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

        for (long i = 0; i < RARRAY_LEN(temp); i++) {
            VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
            VALUE value = rb_ary_entry(rb_ary_entry(temp, i), 1);

            (*map)[StringValuePtr(key)] = StringValuePtr(value);
        }
        
        m->item().s_voidp = map;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    case Marshall::ToVALUE:
    {
        std::map<std::string,std::string> *map = static_cast<std::map<std::string,std::string> *>(m->item().s_voidp);
        if (map == 0) {
            *(m->var()) = Qnil;
            break;
        }
        
        VALUE hv = rb_hash_new();

        for (   std::map<std::string,std::string>::const_iterator i = map->begin();
                i != map->end(); 
                ++i )
        {            
            rb_hash_aset(hv, rb_str_new2(i->first.c_str()), rb_str_new2(i->second.c_str()));
        }
        
        *(m->var()) = hv;
        m->next();
        
        if (m->cleanup()) {
            delete map;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

DEF_SIGNAL_MARSHALLER( EventSignalWKeyEvent, Wt::Ruby::eventsignal_wkey_event_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( EventSignalWMouseEvent, Wt::Ruby::eventsignal_wmouse_event_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( EventSignalWResponseEvent, Wt::Ruby::eventsignal_wresponse_event_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( EventSignalWScrollEvent, Wt::Ruby::eventsignal_wscroll_event_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( EventSignalVoid, Wt::Ruby::eventsignal_void_class, "Wt::EventSignalBase" )

DEF_SIGNAL_MARSHALLER( SignalBoolean, Wt::Ruby::signal_boolean_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalInt, Wt::Ruby::signal_int_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalIntInt, Wt::Ruby::signal_int_int_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalOrientationIntInt, Wt::Ruby::signal_orientation_int_int_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalIntIntIntInt, Wt::Ruby::signal_int_int_int_int_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalLonglongLonglong, Wt::Ruby::signal_longlong_longlong_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalEnum, Wt::Ruby::signal_enum_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWDate, Wt::Ruby::signal_wdate_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWMenuItem, Wt::Ruby::signal_wmenuitem_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWWidget, Wt::Ruby::signal_wwidget_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWModelIndex, Wt::Ruby::signal_wmodelindex_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWModelIndexIntInt, Wt::Ruby::signal_wmodelindex_int_int_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWModelIndexWModelIndex, Wt::Ruby::signal_wmodelindex_wmodelindex_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWModelIndexWMouseEvent, Wt::Ruby::signal_wmodelindex_wmouseevent_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWStandardItem, Wt::Ruby::signal_wstandarditem_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalWString, Wt::Ruby::signal_wstring_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalString, Wt::Ruby::signal_string_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( SignalStringString, Wt::Ruby::signal_string_string_class, "Wt::SignalBase" )
DEF_SIGNAL_MARSHALLER( Signal, Wt::Ruby::signal_class, "Wt::SignalBase" )

DEF_SIGNAL_MARSHALLER( JSignal, Wt::Ruby::jsignal_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( JSignalBoolean, Wt::Ruby::jsignal_boolean_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( JSignalIntInt, Wt::Ruby::jsignal_int_int_class, "Wt::EventSignalBase" )
DEF_SIGNAL_MARSHALLER( JSignalInt, Wt::Ruby::jsignal_int_class, "Wt::EventSignalBase" )

#if WT_VERSION >= 0x02990000
DEF_SIGNAL_MARSHALLER( JSignalWGoogleMapCoordinate, Wt::Ruby::jsignal_wgooglemap_coordinate_class, "Wt::EventSignalBase" )
#endif

DEF_LIST_MARSHALLER( WWidgetVector, std::vector<Wt::WWidget*>, Wt::WWidget )
DEF_LIST_MARSHALLER( WAbstractAreaVector, std::vector<Wt::WAbstractArea*>, Wt::WAbstractArea )
DEF_LIST_MARSHALLER( WMenuItemVector, std::vector<Wt::WMenuItem*>, Wt::WMenuItem )
DEF_LIST_MARSHALLER( WStandardItemVector, std::vector<Wt::WStandardItem*>, Wt::WStandardItem )
DEF_LIST_MARSHALLER( WTreeNodeVector, std::vector<Wt::WTreeNode*>, Wt::WTreeNode )
// DEF_LIST_MARSHALLER( DomElementVector, std::vector<Wt::DomElement*>, Wt::DomElement )
DEF_LIST_MARSHALLER( WObjectVector, std::vector<Wt::WObject*>, Wt::WObject )
DEF_LIST_MARSHALLER( WRadioButtonVector, std::vector<Wt::WRadioButton*>, Wt::WRadioButton )

#if WT_VERSION >= 0x0299000000
DEF_VALUELIST_MARSHALLER( WGoogleMapCoordinateVector, std::vector<Wt::WGoogleMap::Coordinate>, Wt::WGoogleMap::Coordinate )
#endif

DEF_VALUELIST_MARSHALLER( WPointVector, std::vector<Wt::WPoint>, Wt::WPoint )
DEF_VALUELIST_MARSHALLER( WPointFVector, std::vector<Wt::WPointF>, Wt::WPointF )
DEF_VALUELIST_MARSHALLER( ChartWDataSeriesVector, std::vector<Wt::Chart::WDataSeries>, Wt::Chart::WDataSeries )
DEF_VALUELIST_MARSHALLER( WLineFVector, std::vector<Wt::WLineF>, Wt::WLineF )
DEF_VALUELIST_MARSHALLER( WLoggerFieldVector, std::vector<Wt::WLogger::Field>, Wt::WLogger::Field )
DEF_VALUELIST_MARSHALLER( WPainterPathSegmentVector, std::vector<Wt::WPainterPath::Segment>, Wt::WPainterPath::Segment )
DEF_VALUELIST_MARSHALLER( WRectFVector, std::vector<Wt::WRectF>, Wt::WRectF )
DEF_VALUELIST_MARSHALLER( WModelIndexVector, std::vector<Wt::WModelIndex>, Wt::WModelIndex )

DEF_SET_MARSHALLER( WTreeNodeSet, std::set<Wt::WTreeNode*>, Wt::WTreeNode, std::set<Wt::WTreeNode*>::iterator )

DEF_VALUESET_MARSHALLER( WDateSet, std::set<Wt::WDate>, Wt::WDate, std::set<Wt::WDate>::iterator )
DEF_VALUESET_MARSHALLER( WModelIndexSet, std::set<Wt::WModelIndex>, Wt::WModelIndex, std::set<Wt::WModelIndex>::iterator )

WTRUBY_EXPORT TypeHandler Wt_handlers[] = {
    { "Cursor", marshall_StaticConstEnum },
    { "HorizontalAlignment", marshall_StaticConstEnum },
    { "PositionScheme", marshall_StaticConstEnum },
    { "Side", marshall_StaticConstEnum },
    { "VerticalAlignment", marshall_StaticConstEnum },
    { "Wt::EventSignal<Wt::WKeyEvent>", marshall_EventSignalWKeyEvent },
    { "Wt::EventSignal<Wt::WKeyEvent>&", marshall_EventSignalWKeyEvent },
    { "Wt::EventSignal<Wt::WKeyEvent>*", marshall_EventSignalWKeyEvent },
    { "Wt::EventSignal<Wt::WMouseEvent>", marshall_EventSignalWMouseEvent },
    { "Wt::EventSignal<Wt::WMouseEvent>&", marshall_EventSignalWMouseEvent },
    { "Wt::EventSignal<Wt::WMouseEvent>*", marshall_EventSignalWMouseEvent },
    { "Wt::EventSignal<Wt::WResponseEvent>", marshall_EventSignalWResponseEvent },
    { "Wt::EventSignal<Wt::WResponseEvent>&", marshall_EventSignalWResponseEvent },
    { "Wt::EventSignal<Wt::WScrollEvent>&", marshall_EventSignalWScrollEvent },
    { "Wt::EventSignal<Wt::WScrollEvent>*", marshall_EventSignalWScrollEvent },
    { "Wt::EventSignal<>", marshall_EventSignalVoid },
    { "Wt::EventSignal<>&", marshall_EventSignalVoid },
    { "Wt::EventSignal<void>", marshall_EventSignalVoid },
    { "Wt::EventSignal<void>&", marshall_EventSignalVoid },
    { "Wt::EventSignal<void>*", marshall_EventSignalVoid },
    { "Wt::JSignal<>", marshall_JSignal },
    { "Wt::JSignal<>&", marshall_JSignal },
    { "Wt::JSignal<bool>", marshall_JSignalBoolean },
    { "Wt::JSignal<bool>&", marshall_JSignalBoolean },
    { "Wt::JSignal<int,int>", marshall_JSignalIntInt },
    { "Wt::JSignal<int,int>&", marshall_JSignalIntInt },
    { "Wt::JSignal<int>", marshall_JSignalInt },
    { "Wt::JSignal<int>&", marshall_JSignalInt },
#if WT_VERSION >= 0x02990000
    { "Wt::JSignal<Wt::WGoogleMap::Coordinate>", marshall_JSignalWGoogleMapCoordinate },
    { "Wt::JSignal<Wt::WGoogleMap::Coordinate>&", marshall_JSignalWGoogleMapCoordinate },
    { "std::vector<Wt::WGoogleMap::Coordinate>", marshall_WGoogleMapCoordinateVector },
    { "std::vector<Wt::WGoogleMap::Coordinate>&", marshall_WGoogleMapCoordinateVector },
#endif
    { "Wt::Signal<bool>", marshall_SignalBoolean },
    { "Wt::Signal<bool>&", marshall_SignalBoolean },
    { "Wt::Signal<int,int>",  marshall_SignalIntInt },
    { "Wt::Signal<int,int>&",  marshall_SignalIntInt },
    { "Wt::Signal<Wt::Orientation,int,int>",  marshall_SignalOrientationIntInt },
    { "Wt::Signal<Wt::Orientation,int,int>&",  marshall_SignalOrientationIntInt },
    { "Wt::Signal<int>", marshall_SignalInt },
    { "Wt::Signal<int>&", marshall_SignalInt },
    { "Wt::Signal<long long,long long>",  marshall_SignalLonglongLonglong },
    { "Wt::Signal<long long,long long>&",  marshall_SignalLonglongLonglong },
    { "Wt::Signal<int64_t,int64_t>&",  marshall_SignalLonglongLonglong },
    { "Wt::Signal<>",  marshall_Signal },
    { "Wt::Signal<>&",  marshall_Signal },
    { "Wt::Signal<std::string>",  marshall_SignalString },
    { "Wt::Signal<std::string>&",  marshall_SignalString },
    { "Wt::Signal<std::string,std::string>",  marshall_SignalStringString },
    { "Wt::Signal<std::string,std::string>&",  marshall_SignalStringString },
    { "Wt::Signal<void>",  marshall_Signal },
    { "Wt::Signal<void>&",  marshall_Signal },
    { "Wt::Signal<Wt::Ext::Dialog::DialogCode>", marshall_SignalEnum },
    { "Wt::Signal<Wt::Ext::Dialog::DialogCode>&", marshall_SignalEnum },
    { "Wt::Signal<Wt::StandardButton>", marshall_SignalEnum },
    { "Wt::Signal<Wt::StandardButton>&", marshall_SignalEnum },
    { "Wt::Signal<Wt::WDialog::DialogCode>", marshall_SignalEnum },
    { "Wt::Signal<Wt::WDialog::DialogCode>&", marshall_SignalEnum },
    { "Wt::Signal<Wt::WDate>", marshall_SignalWDate },
    { "Wt::Signal<Wt::WDate>&", marshall_SignalWDate },
    { "Wt::Signal<Wt::WMenuItem*>", marshall_SignalWMenuItem },
    { "Wt::Signal<Wt::WMenuItem*>&", marshall_SignalWMenuItem },
    { "Wt::Signal<Wt::WModelIndex>", marshall_SignalWModelIndex },
    { "Wt::Signal<Wt::WModelIndex>&", marshall_SignalWModelIndex },
    { "Wt::Signal<Wt::WModelIndex,int,int>", marshall_SignalWModelIndexIntInt },
    { "Wt::Signal<Wt::WModelIndex,int,int>&", marshall_SignalWModelIndex },
    { "Wt::Signal<Wt::WModelIndex,Wt::WModelIndex>", marshall_SignalWModelIndexWModelIndex },
    { "Wt::Signal<Wt::WModelIndex,Wt::WModelIndex>&", marshall_SignalWModelIndexWModelIndex },
    { "Wt::Signal<Wt::WModelIndex,Wt::WMouseEvent>", marshall_SignalWModelIndexWMouseEvent },
    { "Wt::Signal<Wt::WModelIndex,Wt::WMouseEvent>&", marshall_SignalWModelIndexWMouseEvent },
    { "Wt::Signal<Wt::WStandardItem*>",  marshall_SignalWStandardItem }, 
    { "Wt::Signal<Wt::WStandardItem*>&",  marshall_SignalWStandardItem }, 
    { "Wt::Signal<Wt::WString>",  marshall_SignalWString }, 
    { "Wt::Signal<Wt::WString>&",  marshall_SignalWString }, 
    { "Wt::Signal<Wt::WWidget*>", marshall_SignalWWidget },
    { "Wt::TextFormat", marshall_StaticConstEnum },
    { "Wt::WResource::ArgumentMap", marshall_WResourceArgumentMap },
    { "Wt::WResource::ArgumentMap&", marshall_WResourceArgumentMap },
    { "Wt::WString", marshall_WString },
    { "Wt::WString&", marshall_WString },
    { "Wt::WString*", marshall_WString },
    { "bool&", marshall_it<bool *> },
    { "bool*", marshall_it<bool *> },
    { "char*",marshall_it<char *> },
    { "char**", marshall_charP_array },
    { "double&", marshall_doubleR },
    { "double*", marshall_doubleR },
    { "int&", marshall_it<int *> },
    { "int*", marshall_it<int *> },
    { "int64_t", marshall_it<long long> },
    { "long long int", marshall_it<long long> },
    { "long long int&", marshall_it<long long> },
    { "long long", marshall_it<long long> },
    { "long long&", marshall_it<long long> },
    { "quint32&", marshall_it<unsigned int *> },
    { "signed int&", marshall_it<int *> },
    { "std::map<int,boost::any>", marshall_IntBoostAnyMap},
    { "std::map<int,boost::any>&", marshall_IntBoostAnyMap},
    { "std::map<std::string,std::string>", marshall_StringStringMap},
    { "std::map<std::string,std::string>&", marshall_StringStringMap},
    { "std::map<std::string,std::vector<std::string> >", marshall_WResourceArgumentMap},
    { "std::map<std::string,std::vector<std::string> >&", marshall_WResourceArgumentMap},
    { "std::ostream", marshall_StdOStream },
    { "std::ostream&", marshall_StdOStream },
    { "std::set<Wt::WDate>&", marshall_WDateSet },
    { "std::set<Wt::WModelIndex>", marshall_WModelIndexSet },
    { "std::set<Wt::WModelIndex>&", marshall_WModelIndexSet },
    { "std::set<Wt::WTreeNode*>&", marshall_WTreeNodeSet },
    { "std::set<int>&", marshall_StdIntSet },
    { "std::string", marshall_StdString },
    { "std::string&", marshall_StdString },
    { "std::string*", marshall_StdString },
    { "std::vector<Wt::Chart::WDataSeries>&", marshall_ChartWDataSeriesVector },
    { "std::vector<Wt::WAbstractArea*>", marshall_WAbstractAreaVector },
    { "std::vector<Wt::WLineF>&", marshall_WLineFVector },
    { "std::vector<Wt::WLogger::Field>&", marshall_WLoggerFieldVector },
    { "std::vector<Wt::WMenuItem*>&", marshall_WMenuItemVector },
    { "std::vector<Wt::WModelIndex>", marshall_WModelIndexVector },
    { "std::vector<Wt::WObject*>&", marshall_WObjectVector },
    { "std::vector<Wt::WPainterPath::Segment>&", marshall_WPainterPathSegmentVector },
    { "std::vector<Wt::WPoint>&", marshall_WPointVector },
    { "std::vector<Wt::WPointF>&", marshall_WPointFVector },
    { "std::vector<Wt::WRadioButton*>", marshall_WRadioButtonVector },
    { "std::vector<Wt::WRadioButton*>&", marshall_WRadioButtonVector },
    { "std::vector<Wt::WRectF>&", marshall_WRectFVector },
    { "std::vector<Wt::WStandardItem*>", marshall_WStandardItemVector },
    { "std::vector<Wt::WStandardItem*>&", marshall_WStandardItemVector },
    { "std::vector<Wt::WString>", marshall_WStringVector },
    { "std::vector<Wt::WString>&", marshall_WStringVector },
    { "std::vector<Wt::WTreeNode*>&", marshall_WTreeNodeVector },
    { "std::vector<Wt::WWidget*>&", marshall_WWidgetVector },
    { "std::vector<char>", marshall_StdCharVector },
    { "std::vector<char>&", marshall_StdCharVector },
    { "std::vector<unsigned char>", marshall_StdCharVector },
    { "std::vector<unsigned char>&", marshall_StdCharVector },
    { "std::vector<std::string>", marshall_StdStringVector },
    { "std::vector<std::string>&", marshall_StdStringVector },
    { "std::wstring", marshall_StdWString },
    { "std::wstring&", marshall_StdWString },
    { "std::wstring*", marshall_StdWString },
    { "uchar*", marshall_ucharP },
    { "uint&", marshall_it<unsigned int *> },
    { "unsigned int&", marshall_it<unsigned int *> },
    { "uint64_t", marshall_it<long long> },
    { "unsigned long long int", marshall_it<long long> },
    { "unsigned long long int&", marshall_it<long long> },
    { "void", marshall_void },
    { "void**", marshall_voidP_array },

    { 0, 0 }
};

std::map<std::string, TypeHandler*> type_handlers;

void install_handlers(TypeHandler *h) {
    while (h->name != 0) {
        type_handlers[h->name] = h;
        h++;
    }
}

Marshall::HandlerFn getMarshallFn(const SmokeType &type) {
    if (type.elem()) {
        return marshall_basetype;
    }

    if (type.name() == 0) {
        return marshall_void;
    }

    TypeHandler *h = type_handlers[type.name()];
    
    if (h == 0 && type.isConst() && strlen(type.name()) > strlen("const ")) {
        h = type_handlers[type.name() + strlen("const ")];
    }
    
    if (h != 0) {
        return h->fn;
    }

    return marshall_unknown;
}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
