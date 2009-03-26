#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
# @addtogroup styleexample
#
# The CornerImage is an image to draw a rounded corner.
#
# The CornerImage is a dynamically generated WImage, which draws
# an arc of 90�, to represent one of the four corners of a widget.
#
# The CornerImage is part of the Wt style example.
#
# RoundedWidget
#
class CornerImage < Wt::WImage
  # We want an anti-aliased image: oversample twice
  AA = 2

  TopLeft = Wt::Top | Wt::Left
  TopRight = Wt::Top | Wt::Right
  BottomLeft = Wt::Bottom | Wt::Left
  BottomRight = Wt::Bottom | Wt::Right

  def initialize(c, fg, bg, radius, parent = nil)
    super()
    @corner = c
    @fg = fg
    @bg = bg
    @radius = radius
    @resource = nil
    compute
  end

  def radius
    return @radius
  end

  def radius=(radius)
    if radius != @radius
      @radius = radius
      compute
    end
  end

  def foreground
    return @fg
  end

  def foreground=(color)
    if @fg != color
      @fg = color
      compute
    end
  end

  def compute
    imBig = GD::Image.new(@radius * AA, @radius * AA)

    # automatically becomes the background color -- gd documentation
    imBig.colorAllocate(@bg.red, @bg.green, @bg.blue)
  
    fgColor = imBig.colorAllocate(@fg.red, @fg.green, @fg.blue)

    if (@corner & Wt::Top) != 0
      cy = @radius * AA - 1
    else
      cy = 0
    end
  
    if (@corner & Wt::Left) != 0
      cx = @radius * AA - 1
    else
      cx = 0
    end

    imBig.filledArc(cx, cy, (@radius*2 - 1) * AA, (@radius*2 - 1) * AA, 0, 360, fgColor, GD::Arc)
  
    # now create the real image, downsampled by a factor of 2
    im = GD::Image.newTrueColor(@radius, @radius)
    imBig.copyResampled(im, 0, 0, 0, 0, im.width, im.height, imBig.width, imBig.height)
  
    # and generate an in-memory png file */
    data = im.pngStr
    if !data
      return
      # Error 
    end
  
    if @resource
      @resource.data = data
    else
      # create and set the memory resource that contains the image
      @resource = Wt::WMemoryResource.new("image/png")
      @resource.data = data
      setResource(@resource)
    end
    
    im.destroy
    imBig.destroy
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
