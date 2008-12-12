/***************************************************************************
                          wtext.cpp  -  Wt::Ext ruby extension
                             -------------------
    begin                : 30-08-2008
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

#include <ruby.h>

#include <smoke/wtext_smoke.h>
#include <wtruby.h>

#include <iostream>

static VALUE getClassList(VALUE /*self*/)
{
    VALUE classList = rb_ary_new();
    for (int i = 1; i < wtext_Smoke->numClasses; i++) {
        if (wtext_Smoke->classes[i].className && !wtext_Smoke->classes[i].external) {
            rb_ary_push(classList, rb_str_new2(wtext_Smoke->classes[i].className));
        }
    }
    return classList;
}

const char*
resolve_classname_wtext(smokeruby_object * o)
{
    return Wt::Ruby::modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler WtExt_handlers[];

extern "C" {

VALUE wtext_module;
VALUE wtext_internal_module;

static Wt::Ruby::Binding binding;

WTRUBY_EXPORT void
Init_wtext()
{
    if (wtext_Smoke == 0) {
        init_wtext_Smoke();
    }

    Wt::Ruby::smokeList.push_back(wtext_Smoke);

    binding = Wt::Ruby::Binding(wtext_Smoke);
    Wt::Ruby::Module module = { "Wt::Ext", resolve_classname_wtext, 0, &binding };
    Wt::Ruby::modules[wtext_Smoke] = module;
    install_handlers(WtExt_handlers);

    wtext_module = rb_define_module_under(Wt::Ruby::wt_module, "Ext");
    wtext_internal_module = rb_define_module_under(wtext_module, "Internal");

    rb_define_singleton_method(wtext_internal_module, "getClassList", (VALUE (*) (...)) getClassList, 0);

    rb_require("wt/wtext.rb");
    rb_funcall(wtext_internal_module, rb_intern("init_all_classes"), 0);
}

}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
