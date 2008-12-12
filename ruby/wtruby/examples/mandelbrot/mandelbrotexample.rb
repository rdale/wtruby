#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'GD'
require 'mandelbrotimage.rb'

class MandelbrotExample < Wt::WContainerWidget

  def initialize(parent = nil)
    super(parent)
    Wt::WText.new("<h2>Wt Mandelbrot example</h2>" \
              "<p>The image below is a WVirtualImage that renders the " \
              "classic Mandelbrot fractal.</p>" \
              "<p>It is drawn as a grid of many smaller images, " \
              "computed on the fly, as you scroll around " \
              "through the virtual image. You can scroll the image using the " \
              "buttons, or by dragging the mouse.</p>", self)
  
    layout = Wt::WTable.new(self)
=begin
    @mandelbrot = MandelbrotImage.new(400, 400,
                                      3000, 3000,
                                      -2,
                                      -1.5,
                                      1,
                                      1.5, layout.elementAt(0, 0))
=end
    @mandelbrot = MandelbrotImage.new(400, 400,
                                      500, 500,
                                      -2,
                                      -1.5,
                                      1,
                                      1.5, layout.elementAt(0, 0))

    buttons = Wt::WContainerWidget.new(layout.elementAt(0, 0))
    buttons.resize(Wt::WLength.new(400), Wt::WLength.new)
    buttons.contentAlignment = Wt::AlignCenter
  
    (Wt::WPushButton.new("Left", buttons)).clicked.connect(SLOT(self, :moveLeft))
    (Wt::WPushButton.new("Right", buttons)).clicked.connect(SLOT(self, :moveRight))
    (Wt::WPushButton.new("Up", buttons)).clicked.connect(SLOT(self, :moveUp))
    (Wt::WPushButton.new("Down", buttons)).clicked.connect(SLOT(self, :moveDown))
  
    Wt::WBreak.new(buttons)
  
    (Wt::WPushButton.new("Zoom in", buttons)).clicked.connect(SLOT(self, :zoomIn))
    (Wt::WPushButton.new("Zoom out", buttons)).clicked.connect(SLOT(self, :zoomOut))
  
    @viewPortText = Wt::WText.new(layout.elementAt(0, 1))
    layout.elementAt(0, 1).margin = Wt::WLength.new(10)
  
    updateViewPortText
  
    @mandelbrot.viewPortChanged.connect(SLOT(self, :updateViewPortText))
  end

  def moveLeft
    @mandelbrot.scroll(-50, 0)
  end

  def moveRight
    @mandelbrot.scroll(50, 0)
  end

  def moveUp
    @mandelbrot.scroll(0, -50)
  end

  def moveDown
    @mandelbrot.scroll(0, 50)
  end

  def zoomIn
    @mandelbrot.zoomIn
  end

  def zoomOut
    @mandelbrot.zoomOut
  end

  def updateViewPortText
    @viewPortText.text = "Current viewport: (%s,%s) to (%s,%s)" %
                          [@mandelbrot.currentX1, @mandelbrot.currentY1,
                          @mandelbrot.currentX2, @mandelbrot.currentY2]
  end
end

Wt::WRun(ARGV) do |env|
  GC.disable
  app = Wt::WApplication.new(env)
  app.title = "Wt Mandelbrot example"
  app.root.addWidget(MandelbrotExample.new)
  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
