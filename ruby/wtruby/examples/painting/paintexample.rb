#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'shapeswidget.rb'

class PaintExample < Wt::WContainerWidget

  def initialize(root)
    super(root)

    Wt::WText.new("<h2>Paint example</h2>" \
      "<p>A simple example demonstrating cross-browser vector graphics." \
      "</p>" \
      "<p>The emweb logo below is painted using the Wt WPainter API, and " \
      "rendered to the browser using inline SVG, inline VML or the " \
      "HTML 5 &lt;canvas&gt; element." \
      "</p>",
      root)

    layout = Wt::WGridLayout.new

    emweb = Wt::WContainerWidget.new(root) do |e|
      e.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
      e.setLayout(layout, Wt::AlignCenter | Wt::AlignTop)
    end

    scaleSlider = Wt::WSlider.new(Wt::Horizontal) do |s|
      s.range = 0..20
      s.value = 10
      s.tickInterval = 5
      s.tickPosition = Wt::WSlider::TicksBothSides
      s.resize(Wt::WLength.new(300), Wt::WLength.new(50))
      s.valueChanged.connect(SLOT(self, :scaleShape))
    end

    layout.addWidget(scaleSlider, 0, 1, Wt::AlignCenter | Wt::AlignMiddle)
  
    rotateSlider = Wt::WSlider.new(Wt::Vertical) do |r|
      r.range = -30..30
      r.value = 0
      r.tickInterval = 10
      r.tickPosition = Wt::WSlider::TicksBothSides
      r.resize(Wt::WLength.new(50), Wt::WLength.new(400))
      r.valueChanged.connect(SLOT(self, :rotateShape))
    end

    layout.addWidget(rotateSlider, 1, 0, Wt::AlignCenter | Wt::AlignMiddle)
  
    @shapes = ShapesWidget.new do |s|
      s.angle = 0.0
      s.relativeSize = 0.5
      s.preferredMethod = Wt::WPaintedWidget::InlineSvgVml
    end

    layout.addWidget(@shapes, 1, 1, Wt::AlignCenter | Wt::AlignMiddle)
  end

  def rotateShape(v)
    @shapes.angle = v / 2.0
  
    # Being silly: test alternate rendering method
    @shapes.setPreferredMethod(v < 0 ? Wt::WPaintedWidget::InlineSvgVml : Wt::WPaintedWidget::HtmlCanvas)
  end

  def scaleShape(v)
    @shapes.relativeSize = 0.1 + 0.9 * (v/20.0)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
