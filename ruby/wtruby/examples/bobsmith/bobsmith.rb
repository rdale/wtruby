#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale

require 'wt'

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)

  Wt::WText.new("Name: ", app.root)
  edit = Wt::WInPlaceEdit.new("Bob Smith", app.root)
  edit.styleClass = "inplace"

  app.styleSheet.addRule("*.inplace span:hover", "background-color: Wt::gray")

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
