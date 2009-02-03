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

#include <Wt/WButtonGroup>

#include <ruby.h>

#include <smoke/wtext_smoke.h>
#include <wtruby.h>

#include <iostream>
#include <cstring>

namespace Wt {
  namespace Ruby {
    static VALUE wt_wbuttongroup_class;
  }
}

static VALUE
wbuttongroup_addbutton(int argc, VALUE * argv, VALUE self)
{
    if (    argc == 1 
            && std::strcmp(rb_obj_classname(argv[0]), "Wt::Ext::RadioButton") == 0 )
    {
        smokeruby_object *o = value_obj_info(self);
        Wt::WButtonGroup * group = static_cast<Wt::WButtonGroup *>(o->ptr);

        smokeruby_object *b = value_obj_info(argv[0]);
        Wt::Ext::RadioButton * button = static_cast<Wt::Ext::RadioButton *>(b->ptr);

        group->addButton(button);
        return self;
    }

    rb_call_super(argc, argv);
}

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

    Wt::Ruby::wt_wbuttongroup_class = rb_define_class_under(Wt::Ruby::wt_module, "WButtonGroup", Wt::Ruby::wt_base_class);
    rb_define_method(Wt::Ruby::wt_wbuttongroup_class, "addButton", (VALUE (*) (...)) wbuttongroup_addbutton, -1);
    rb_define_method(Wt::Ruby::wt_wbuttongroup_class, "add_button", (VALUE (*) (...)) wbuttongroup_addbutton, -1);

    rb_define_singleton_method(wtext_internal_module, "getClassList", (VALUE (*) (...)) getClassList, 0);

    rb_require("wt/wtext.rb");
    rb_funcall(wtext_internal_module, rb_intern("init_all_classes"), 0);
}

}

// kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
