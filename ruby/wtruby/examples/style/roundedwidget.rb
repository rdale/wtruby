#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#*
# styleexample
#
# A widget with rounded corners.
#
# This widgets represents a widget for which any combination of its four
# corners may be rounded. Although rounded corners is not a standard part
# of the CSS specification, self widget will be rendered identical on
# all platforms.
#
# The contents of the widget is managed inside a WContainerWidget, which
# is accessed using the contents() method.
#
# The radius of the rounded corners, the background color of the image,
# and the surrounding color may be changed at all times.
#
# The RoundedWidget is part of the Wt style example.
#
#
class RoundedWidget < Wt::WCompositeWidget
  attr_reader :contents, :backgroundColor, :surroundingColor

  TopLeft = CornerImage::TopLeft
  TopRight = CornerImage::TopRight
  BottomLeft = CornerImage::BottomLeft
  BottomRight = CornerImage::BottomRight
  All = 0xF

  def initialize(corners, parent = nil)
    super(parent)
    @backgroundColor = Wt::WColor.new(0xD4,0xDD,0xFF)
    @surroundingColor = Wt::WColor.new(0xFF,0xFF,0xFF)
    @radius = 10
    @corners = corners
    @impl = Wt::WContainerWidget.new
    setImplementation(@impl)
    @contents = Wt::WContainerWidget.new(@impl)
    @images = []
    create
  end

  def create
    if (@corners & TopLeft.to_i) != 0
      @images[0] = CornerImage.new(CornerImage::TopLeft, @backgroundColor, @surroundingColor, @radius)
      @images[0].positionScheme = Wt::Absolute
    else
      @images[0] = nil
    end
  
    if (@corners & TopRight.to_i) != 0
      @images[1] = CornerImage.new(CornerImage::TopRight, @backgroundColor, @surroundingColor, @radius)
    else
      @images[1] = nil
    end
  
    if (@corners & BottomLeft.to_i) != 0
      @images[2] = CornerImage.new(CornerImage::BottomLeft, @backgroundColor, @surroundingColor, @radius)
      @images[2].positionScheme = Wt::Absolute
    else
      @images[2] = nil
    end
  
    if (@corners & BottomRight.to_i) != 0
      @images[3] = CornerImage.new(CornerImage::BottomRight, @backgroundColor, @surroundingColor, @radius)
    else
      @images[3] = nil
    end
  
    #
    # At the top: an image (top left corner) inside
    # a container widget with background image top right.
    #
    @top = Wt::WContainerWidget.new
    @top.resize(Wt::WLength.new, Wt::WLength.new(@radius))
    @top.positionScheme = Wt::Relative
    if @images[1]
      @top.decorationStyle.setBackgroundImage(@images[1].imageRef, Wt::WCssDecorationStyle::NoRepeat,
                                                                  Wt::Top | Wt::Right )
    end
    if @images[0]
      @top.addWidget(@images[0])
    end
    @impl.insertBefore(@top, @contents) # insert top before the contents
  
    #
    # At the bottom: an image (bottom left corner) inside
    # a container widget with background image bottom right.
    #
    @bottom = Wt::WContainerWidget.new
    @bottom.positionScheme = Wt::Relative
    @bottom.resize(Wt::WLength.new, Wt::WLength.new(@radius))
    if @images[3]
      @bottom.decorationStyle.setBackgroundImage(@images[3].imageRef,  Wt::WCssDecorationStyle::NoRepeat,
                                                                      Wt::Bottom | Wt::Right )
    end
    if @images[2]
      @bottom.addWidget(@images[2])
    end
    @impl.addWidget(@bottom)
  
    decorationStyle.backgroundColor = @backgroundColor
  
    @contents.margin = Wt::WLength.new(@radius, Wt::Left | Wt::Right)
  end

  def backgroundColor=(color)
    @backgroundColor = color
    adjust
  end

  def surroundingColor=(color)
    @surroundingColor = color
    adjust
  end

  def cornerRadius
    return @radius
  end

  def cornerRadius=(radius)
    @radius = radius
    adjust
  end

  def enableRoundedCorners(how)
    if @images[0]
      @images[0].setHidden(!how)
    end
    if @images[2] 
      @images[2].setHidden(!how)
    end
    if @images[1]
    end

    @images[1].setHidden(!how)
    if !how
      @top.decorationStyle.setBackgroundImage("")
    else
      @top.decorationStyle.setBackgroundImage( @images[1].imageRef,
                                               Wt::WCssDecorationStyle::NoRepeat,
                                               Wt::Top | Wt::Right )
    end

    if @images[3]
      @images[3].setHidden(!how)
    end

    if !how
      @bottom.decorationStyle.backgroundImage = ""
    else
      @bottom.decorationStyle.setBackgroundImage( @images[3].imageRef,
                                                  Wt::WCssDecorationStyle::NoRepeat,
                                                  Wt::Top | Wt::Right )
    end
  end

  def adjust
    if @images[0] && !@images[0].isHidden
      @images[0].radius = @radius
    end
    if @images[1] && !@images[1].isHidden
      @images[1].radius = @radius
    end
    if @images[2] && !@images[2].isHidden
      @images[2].radius =@radius
    end
    if @images[3] && !@images[3].isHidden
      @images[3].radius = @radius
    end

    if @images[0] && !@images[0].isHidden
      @images[0].foreground = @backgroundColor
    end
    if @images[1] && !@images[1].isHidden
      @images[1].foreground = @backgroundColor
    end
    if @images[2] && !@images[2].isHidden
      @images[2].foreground = @backgroundColor
    end
    if @images[3] && !@images[3].isHidden
      @images[3].foreground = @backgroundColor
    end

    if @images[1]
      @top.decorationStyle.setBackgroundImage(  @images[1].imageRef,
                                                Wt::WCssDecorationStyle::NoRepeat,
                                                Wt::Top | Wt::Right )
    end
    if @images[3]
      @bottom.decorationStyle.setBackgroundImage( @images[3].imageRef,
                                                  Wt::WCssDecorationStyle::NoRepeat,
                                                  Wt::Bottom | Wt::Right )
    end
    @top.resize(Wt::WLength.new, Wt::WLength.new(@radius))
    @bottom.resize(Wt::WLength.new, Wt::WLength.new(@radius))
    @contents.setMargin(Wt::WLength.new(@radius), Wt::Left | Wt::Right)
  
    decorationStyle.backgroundColor = @backgroundColor
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
