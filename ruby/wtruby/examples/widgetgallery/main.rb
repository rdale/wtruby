#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#

require 'wt'
require 'wtext'

require 'controlswidget.rb'
require 'basiccontrols.rb'
require 'chartwidgets.rb'
require 'deferredwidget.rb'
require 'dialogwidgets.rb'
require 'eventdisplayer.rb'
require 'eventsdemo.rb'
require 'extwidgets.rb'
require 'formwidgets.rb'
require 'graphicswidgets.rb'
require 'mvcwidgets.rb'
require 'stylelayout.rb'
require 'validators.rb'
require 'widgetgallery.rb'

# DUMP_INDENT = '    '
DUMP_INDENT = ''

def dumpWObjects(obj, indent = DUMP_INDENT)
  puts "#{indent}#{obj.inspect}"

  begin
    puts "#{indent}#{DUMP_INDENT}#{obj.layout.inspect}" unless obj.layout.nil?
  rescue
  end

  begin
    dumpWObjects(obj.subMenu, indent + DUMP_INDENT)
  rescue
  end

  begin
    obj.items.each do |item|
      dumpWObjects(item, indent + DUMP_INDENT)
      dumpWObjects(obj.item_contents[item.id], indent + DUMP_INDENT + DUMP_INDENT) unless obj.item_contents[item.id].nil?
    end
  rescue
  end

  begin
    obj.children.each do |child|
      dumpWObjects(child, indent + DUMP_INDENT)
    end
  rescue
  end
end

Wt::WRun(ARGV) do |env|
  WidgetGallery.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
