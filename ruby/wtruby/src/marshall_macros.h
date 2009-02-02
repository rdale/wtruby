/***************************************************************************
  marshall_macros.h  -  Useful template based marshallers for QLists, QVectors
                        and QLinkedLists
                             -------------------
    begin                : Thurs Jun 8 2008
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

#ifndef MARSHALL_MACROS_H
#define MARSHALL_MACROS_H

#define DEF_LIST_MARSHALLER(ListIdent,ItemList,Item) namespace { char ListIdent##STR[] = #Item; }  \
        Marshall::HandlerFn marshall_##ListIdent = marshall_ItemList<Item,ItemList,ListIdent##STR>;

#define DEF_VALUELIST_MARSHALLER(ListIdent,ItemList,Item) namespace { char ListIdent##STR[] = #Item; }  \
        Marshall::HandlerFn marshall_##ListIdent = marshall_ValueListItem<Item,ItemList,ListIdent##STR>;

#define DEF_SET_MARSHALLER(SetIdent,ItemSet,Item,ItemSetIterator) namespace { char SetIdent##STR[] = #Item; }  \
        Marshall::HandlerFn marshall_##SetIdent = marshall_ItemSet<Item,ItemSet,ItemSetIterator,SetIdent##STR>;

#define DEF_VALUESET_MARSHALLER(SetIdent,ItemSet,Item,ItemSetIterator) namespace { char SetIdent##STR[] = #Item; }  \
        Marshall::HandlerFn marshall_##SetIdent = marshall_ItemValueSet<Item,ItemSet,ItemSetIterator,SetIdent##STR>;

#define DEF_SIGNAL_MARSHALLER(SIGNAL_IDENT, CLASS_IDENT, CLASS_NAME) \
void marshall_##SIGNAL_IDENT(Marshall *m) { \
    switch(m->action()) { \
    case Marshall::ToVALUE: \
    { \
        void * ptr = m->item().s_voidp; \
        if (ptr == 0) { \
            *(m->var()) = Qnil; \
        } else { \
            VALUE obj = getPointerObject(ptr); \
            if (obj == Qnil) { \
                smokeruby_object  * o = alloc_smokeruby_object( false,  \
                                                                m->smoke(), \
                                                                m->smoke()->idClass(CLASS_NAME).index, \
                                                                ptr ); \
                obj = Data_Wrap_Struct(CLASS_IDENT, smokeruby_mark, smokeruby_free, (void *) o ); \
            } \
            *(m->var()) = obj; \
        } \
    } \
    break; \
    default: \
        m->unsupported(); \
        break; \
    } \
}

template <class Item, class ItemList, const char *ItemSTR >
void marshall_ItemList(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        ItemList *cpplist = new ItemList;
        long i;
        for (i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            // TODO do type checking!
            smokeruby_object *o = value_obj_info(item);
            if (o == 0 || o->ptr == 0) {
                continue;
			}
            void *ptr = o->ptr;
            ptr = o->smoke->cast(ptr, o->classId, o->smoke->idClass(ItemSTR).index);
            cpplist->push_back((Item *) ptr);
        }

        m->item().s_voidp = cpplist;
        m->next();

        if (!m->type().isConst()) {
            rb_ary_clear(list);

            for (unsigned int i = 0; i < cpplist->size(); ++i ) {
                VALUE obj = getPointerObject((void *) cpplist->at(i));
                rb_ary_push(list, obj);
            }
        }

        if (m->cleanup()) {
            delete cpplist;
        }
    }
    break;
      
    case Marshall::ToVALUE:
    {
        ItemList *valuelist = (ItemList*)m->item().s_voidp;
        if (valuelist == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();

        for (unsigned int i = 0; i < valuelist->size(); ++i) {
            void *p = (void *) valuelist->at(i);

            if (m->item().s_voidp == 0) {
                *(m->var()) = Qnil;
                break;
            }

            VALUE obj = getPointerObject(p);
            if (obj == Qnil) {
                smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                                m->smoke(), 
                                                                m->smoke()->idClass(ItemSTR).index, 
                                                                p );
                obj = set_obj_info(resolve_classname(o), o);
            }
        
            rb_ary_push(av, obj);
        }

        *(m->var()) = av;
        m->next();

        if (m->cleanup()) {
            delete valuelist;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

template <class Item, class ItemList, const char *ItemSTR >
void marshall_ValueListItem(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }
        int count = RARRAY_LEN(list);
        ItemList *cpplist = new ItemList;
        long i;
        for (i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            // TODO do type checking!
            smokeruby_object *o = value_obj_info(item);

            if (o == 0 || o->ptr == 0) {
                continue;
            }

            void *ptr = o->ptr;
            ptr = o->smoke->cast(ptr, o->classId, o->smoke->idClass(ItemSTR).index);
            cpplist->push_back(*(Item*)ptr);
        }

        m->item().s_voidp = cpplist;
        m->next();

        if (!m->type().isConst()) {
            rb_ary_clear(list);
            for (unsigned int i = 0; i < cpplist->size(); ++i) {
                VALUE obj = getPointerObject((void*)&(cpplist->at(i)));
                rb_ary_push(list, obj);
            }
        }

        if (m->cleanup()) {
            delete cpplist;
        }
    }
    break;
      
    case Marshall::ToVALUE:
    {
        ItemList *valuelist = (ItemList*)m->item().s_voidp;
        if(!valuelist) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();

        int ix = m->smoke()->idClass(ItemSTR).index;
        const char * className = Wt::Ruby::modules[m->smoke()].binding->className(ix);

        for (unsigned int i = 0; i < valuelist->size() ; ++i) {
            void *p = (void *) &(valuelist->at(i));

            if(m->item().s_voidp == 0) {
            *(m->var()) = Qnil;
            break;
            }

            VALUE obj = getPointerObject(p);
            if(obj == Qnil) {
                smokeruby_object  * o = alloc_smokeruby_object( false, 
                                                                m->smoke(), 
                                                                m->smoke()->idClass(ItemSTR).index, 
                                                                p );
                obj = set_obj_info(className, o);
            }
    
            rb_ary_push(av, obj);
        }

        *(m->var()) = av;
        m->next();

        if (m->cleanup()) {
            delete valuelist;
        }

    }
    break;
      
    default:
        m->unsupported();
        break;
    }
}

template <class Item, class ItemSet, class ItemSetIterator, const char *ItemSTR >
void marshall_ItemSet(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        ItemSet *stdset = new ItemSet;
        long i;
        for (i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            // TODO do type checking!
            smokeruby_object *o = value_obj_info(item);
            if (o == 0 || o->ptr == 0) {
                continue;
            }
            void *ptr = o->ptr;
            ptr = o->smoke->cast(ptr, o->classId, o->smoke->idClass(ItemSTR).index);
            stdset->insert((Item *) ptr);
        }

        m->item().s_voidp = stdset;
        m->next();

        if (!m->type().isConst()) {
            rb_ary_clear(list);
            for (   ItemSetIterator at = stdset->begin(); 
                    at != stdset->end(); 
                    ++at ) 
            {
                VALUE obj = getPointerObject((void *) *at);
                rb_ary_push(list, obj);
            }
        }

        if (m->cleanup()) {
            delete stdset;
        }
    }
    break;
      
    case Marshall::ToVALUE:
    {
        ItemSet *stdset = (ItemSet*)m->item().s_voidp;
        if (stdset == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();

        for (   ItemSetIterator at = stdset->begin(); 
                at != stdset->end(); 
                ++at ) 
        {
            void *p = (void *) *at;

            if (m->item().s_voidp == 0) {
                *(m->var()) = Qnil;
                break;
            }

            VALUE obj = getPointerObject(p);
            if (obj == Qnil) {
                smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                                m->smoke(), 
                                                                m->smoke()->idClass(ItemSTR).index, 
                                                                p );
                obj = set_obj_info(resolve_classname(o), o);
            }
        
            rb_ary_push(av, obj);
        }

        *(m->var()) = av;
        m->next();

        if (m->cleanup()) {
            delete stdset;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

template <class Item, class ItemSet, class ItemSetIterator, const char *ItemSTR >
void marshall_ItemValueSet(Marshall *m) {
    switch(m->action()) {
    case Marshall::FromVALUE:
    {
        VALUE list = *(m->var());
        if (TYPE(list) != T_ARRAY) {
            m->item().s_voidp = 0;
            break;
        }

        int count = RARRAY_LEN(list);
        ItemSet *stdset = new ItemSet;
        long i;
        for (i = 0; i < count; i++) {
            VALUE item = rb_ary_entry(list, i);
            // TODO do type checking!
            smokeruby_object *o = value_obj_info(item);
            if (o == 0 || o->ptr == 0) {
                continue;
            }
            void *ptr = o->ptr;
            ptr = o->smoke->cast(ptr, o->classId, o->smoke->idClass(ItemSTR).index);
            stdset->insert(*((Item *) ptr));
        }

        m->item().s_voidp = stdset;
        m->next();

        if (!m->type().isConst()) {
            rb_ary_clear(list);
            for (   ItemSetIterator at = stdset->begin(); 
                    at != stdset->end(); 
                    ++at ) 
            {
                VALUE obj = getPointerObject((void *) &(*at));
                rb_ary_push(list, obj);
            }
        }

        if (m->cleanup()) {
            delete stdset;
        }
    }
    break;
      
    case Marshall::ToVALUE:
    {
        ItemSet *stdset = (ItemSet*)m->item().s_voidp;
        if (stdset == 0) {
            *(m->var()) = Qnil;
            break;
        }

        VALUE av = rb_ary_new();

        for (   ItemSetIterator at = stdset->begin(); 
                at != stdset->end(); 
                ++at ) 
        {
            void *p = (void *) &(*at);

            if (m->item().s_voidp == 0) {
                *(m->var()) = Qnil;
                break;
            }

            VALUE obj = getPointerObject(p);
            if (obj == Qnil) {
                smokeruby_object * o = alloc_smokeruby_object(  false, 
                                                                m->smoke(), 
                                                                m->smoke()->idClass(ItemSTR).index, 
                                                                p );
                obj = set_obj_info(resolve_classname(o), o);
            }
        
            rb_ary_push(av, obj);
        }

        *(m->var()) = av;
        m->next();

        if (m->cleanup()) {
            delete stdset;
        }
    }
    break;

    default:
        m->unsupported();
        break;
    }
}

#endif

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
