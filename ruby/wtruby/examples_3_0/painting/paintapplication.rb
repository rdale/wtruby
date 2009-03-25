#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'paintexample.rb'

class PaintApplication < Wt::WApplication
  def initialize(env)
    super(env)
    setTitle("Paint example");
    useStyleSheet("painting.css")
    PaintExample.new(root)
  end
end

Wt::WRun(ARGV) do |env|
  PaintApplication.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
