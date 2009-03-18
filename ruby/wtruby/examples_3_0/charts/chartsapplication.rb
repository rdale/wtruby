#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'wtext'

require 'chartsexample.rb'

class ChartsApplication < Wt::WApplication
  def initialize(env)
    super(env)
    setTitle("Charts example")
    messageResourceBundle.use("charts")
    root.padding = Wt::WLength.new(10)
    ChartsExample.new(root)
    useStyleSheet("charts.css")
  end
end

Wt::WRun(ARGV) do |env|
  ChartsApplication.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
