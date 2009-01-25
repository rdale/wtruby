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

Wt::WRun(ARGV) do |env|
  app = WidgetGallery.new(env)
  # More work needs to be done on coordinating Ruby garbage collection
  # with the Wt runtime, so run with GC disabled for now
  # Wt::Internal::setDebug Wt::WtDebugChannel::WTDB_GC
  GC.disable
  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
