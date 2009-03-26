#!/usr/bin/env ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale

require 'wt'

# Note that you need to build the GD extension
# for this example with '--enable-gd2_0'
require 'GD'

require 'cornerimage.rb'
require 'styleexample.rb'
require 'roundedwidget.rb'

#  styleexample Style example
#
# A demonstration of the RoundedWidget.
#
# This is the main class for the style example.
#
class StyleExample < Wt::WContainerWidget
 # Create a StyleExample.


  LOREMIPSUM = "Lorem ipsum dolor sit amet, consectetur adipisicing " \
   "elit, sed do eiusmod tempor incididunt ut labore et " \
   "dolore magna aliqua. Ut enim ad minim veniam, quis " \
   "nostrud exercitation ullamco laboris nisi ut aliquip " \
   "ex ea commodo consequat. Duis aute irure dolor in " \
   "reprehenderit in voluptate velit esse cillum dolore eu " \
   "fugiat nulla pariatur. Excepteur sint occaecat cupidatat " \
   "non proident, sunt in culpa qui officia deserunt mollit " \
   "anim id est laborum."

  def initialize(parent = nil)
    super(parent)
    @w = RoundedWidget.new(RoundedWidget::All, self)

    Wt::WText.new(LOREMIPSUM, @w.contents)
    Wt::WBreak.new(self)

    Wt::WText.new("Color (rgb): ", self)
    @r = createValidateLineEdit(@w.backgroundColor.red, 0, 255)
    @g = createValidateLineEdit(@w.backgroundColor.green, 0, 255)
    @b = createValidateLineEdit(@w.backgroundColor.blue, 0, 255)
  
    Wt::WBreak.new(self)
  
    Wt::WText.new("Radius (px): ", self)
    @radius = createValidateLineEdit(@w.cornerRadius, 1, 500)
  
    Wt::WBreak.new(self)
  
    p = Wt::WPushButton.new("Update!", self)
    p.clicked.connect(SLOT(self, :updateStyle))
  
    Wt::WBreak.new(self)
  
    @error = Wt::WText.new("", self)
  end

  def createValidateLineEdit(value, min, max)
    le = Wt::WLineEdit.new(value.to_s, self)
    le.textSize = 3
    le.setValidator(Wt::WIntValidator.new(min, max))
  
    return le
  end

  def updateStyle
    if @r.validate != Wt::WValidator::Valid || 
       @g.validate != Wt::WValidator::Valid || 
       @b.validate != Wt::WValidator::Valid
      @error.text = "Color components must be numbers between 0 and 255."
    elsif @radius.validate != Wt::WValidator::Valid
      @error.text = "Radius must be between 1 and 500."
    else
      @w.backgroundColor = Wt::WColor.new(@r.text.to_i, @g.text.to_i, @b.text.to_i)
      @w.cornerRadius = @radius.text.to_i
      @error.text = ""
    end
  end
end

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.title = "Style example"

  app.root.addWidget(StyleExample.new)
  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
