#!/usr/bin/env ruby

# dragexample Drag and Drop example
require 'wt'
require 'dragexample.rb'

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.title = "Drag &amp; drop"
  Wt::WText.new("<h1>Wt Drag &amp; drop example.</h1>", app.root)

  DragExample.new(app.root)
  app.useStyleSheet("dragdrop.css")

  app
end
