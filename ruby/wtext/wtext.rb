=begin
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
=end

module Wt::Ext
  module Internal
    def self.init_all_classes
      getClassList.each do |c|
        classname = Wt::Internal::normalize_classname(c)
        id = Wt::Internal::findClass(c);
        Wt::Internal::insert_pclassid(classname, id)
        Wt::Internal::cpp_names[classname] = c
        klass = Wt::Internal::create_wt_class(classname, Wt::Ext)
        Wt::Internal::classes[classname] = klass unless klass.nil?
      end
    end
  end

  class AbstractButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class AbstractToggleButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Button < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Calendar < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class CheckBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, checked?=%s>" % [id, isChecked])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n checked?=%s>" % [id, isChecked])
    end
  end

  class ComboBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Component < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Container < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class DataStore < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class DateField < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Dialog < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class FormField < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class LineEdit < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Menu < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end

    def addItem(*args)
      if args.length == 2 && args[1].kind_of?(Array)
        item = super(args[0])
        item.activated.connect(args[1])
      elsif args.length == 3 && args[2].kind_of?(Array)
        item = super(args[0], args[1])
        item.activated.connect(args[2])
      else
        super
      end
    end
  end

  class MenuItem < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class MessageBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class NumberField < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class PagingToolBar < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Panel < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class ProgressDialog < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, value=%d, miniumn=%d, maximum=%d>" % [id, value, minimum, maximum])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n value=%d,\n miniumn=%d,\n maximum=%d>" % [id, value, minimum, maximum])
    end

    def range=(arg)
      if arg.kind_of? Range
        setMinimum(arg.begin)
        setMaximum(arg.exclude_end?  ? arg.end - 1 : arg.end)
      else
        return super(arg)
      end
    end
  end

  class RadioButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, checked?=%s>" % [id, isChecked])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n checked?=%s>" % [id, isChecked])
    end
  end

  class Splitter < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class SplitterHandle < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class TabWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class TableView < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class TextEdit < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class ToolBar < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end

    def addButton(*args)
      if args.length == 2 && args[1].kind_of?(Array)
        # Handle calls of the form:
        #     toolBar.addButton("Add 1000 rows", SLOT(self, :addRows))
        #
        button = super(args[0])
        button.activated.connect(args[1])
      elsif args.length == 3 && args[2].kind_of?(Array)
        button = super(args[0], args[1])
        button.activated.connect(args[2])
      else
        super
      end
    end
  end

  class ToolTipConfig < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Widget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end

    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
