#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

class ShapesWidget < Wt::WPaintedWidget

  def initialize(parent = nil)
    super(parent)
    @angle = 0
    resize(Wt::WLength.new(710), Wt::WLength.new(400))
    # the Wt::blue @emweb color
    @emweb = Wt::WColor.new(0x04, 0x7c, 0x93)
  end

  def angle=(angle)
    angle = [-30.0, [30.0, angle].min].max
  
    if @angle != angle
      @angle = angle
      update
    end
  end

  def relativeSize=(size)
    size = [0.1, [1.0, size].min].max

    if @size != size
      @size = size
      update
    end
  end

  def paintEvent(paintDevice)
    painter = Wt::WPainter.new(paintDevice)
  
    painter.renderHint = Wt::WPainter::Antialiasing
  
    painter.translate(width.value/2, height.value/2)
    painter.rotate(@angle)
    painter.scale(@size, @size)
    painter.translate(-width.value/2 + 50, -height.value/2 + 150)
  
    drawEmwebLogo(painter)
  end

  def drawEmwebE(painter)
    p = Wt::WPainterPath.new
  
  # Path copied from our SVG for half of the E */
  
    p.moveTo(46.835084,58.783624)
    p.cubicTo(45.700172,58.783624,35.350098,58.911502,24.656354,63.283309)
    p.cubicTo(8.7595992,69.78907,0,82.38499,0,98.809238)
    p.cubicTo(0,115.20152,8.7595992,127.82141,24.656354,134.31119)
    p.cubicTo(35.350098,138.69099,45.700172,138.81088,46.835084,138.81088)
    p.lineTo(94.509362,138.81088)
    p.lineTo(94.509362,117.58323)
    p.lineTo(46.835084,117.58323)
    p.cubicTo(46.811106,117.58323,39.466151,117.47134,32.608727,114.53815)
    p.cubicTo(25.095932,111.34122,21.747144,106.47389,21.747144,98.809238)
    p.cubicTo(21.747144,91.120612,25.095932,86.269265,32.608727,83.064338)
    p.cubicTo(39.466151,80.123159,46.811106,80.027251,46.89103,80.027251)
    p.lineTo(94.509362,80.027251)
    p.lineTo(94.509362,58.783624)
    p.lineTo(46.835084,58.783624)

    painter.drawPath(p)
  
    painter.save
    painter.translate(0,-58.783624)
    painter.drawPath(p)
    painter.restore
  end

  def drawEmwebMW(painter)
    p = Wt::WPainterPath.new

    # Path copied from our SVG for one fourth of the MW */
  
    p.moveTo(120.59634,24.072913)
    p.cubicTo(116.12064,34.518895,115.98477,44.605222,115.98477,45.732141)
    p.lineTo(115.98477,138.81088)
    p.lineTo(137.7399,138.81088)
    p.lineTo(137.7399,45.732141)
    p.cubicTo(137.7399,45.708164,137.83581,38.53904,140.84892,31.841463)
    p.cubicTo(144.14176,24.512492,149.113,21.235634,156.98545,21.235634)
    p.cubicTo(164.8499,21.235634,169.81314,24.512492,173.10599,31.841463)
    p.cubicTo(176.10311,38.53904,176.215,45.708164,176.215,45.780095)
    p.lineTo(176.215,80.41343)
    p.lineTo(197.97014,80.41343)
    p.lineTo(197.97014,45.732141)
    p.cubicTo(197.97014,44.605222,197.83427,34.518895,193.35057,24.072913)
    p.cubicTo(186.70894,8.5517985,173.77734,0,156.99344,0)
    p.cubicTo(140.17756,0,127.25396,8.5517985,120.59634,24.072913)

    #
    # Paint it four times, translated and inverted
    #
  
    painter.drawPath(p)
  
    dx = 176.0 - 115.98477
  
    painter.save
  
    painter.translate(dx, 0)
    painter.drawPath(p)
  
    painter.translate(dx, 0)
  
    painter.scale(-1, -1)
    painter.translate(0, -138.81088)
    painter.translate(-115.98477 - 197.95 - dx, 0)
    painter.drawPath(p)
  
    painter.translate(dx, 0)
    painter.drawPath(p)
  
    painter.restore
  end

  def drawEmwebLogo(painter)
    painter.save
    painter.pen = Wt::WPen.new(Wt::NoPen)
  
    #
    # The @emweb logo can be drawn as 3 e's, and one combined m/w
    #
  
    # Emweb
    painter.brush = Wt::WBrush.new(Wt::black)
    drawEmwebE(painter)
  
    # emwEb
    painter.save
    painter.translate(397, 0)
    drawEmwebE(painter)
  
    # emweB
    painter.translate(210, 0)
    painter.scale(-1, 1)
    drawEmwebE(painter)
  
    painter.restore
  
    # eMWeb
    painter.brush = Wt::WBrush.new(@emweb)
    drawEmwebMW(painter)
  
    painter.restore
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
