#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

class MandelbrotResource < Wt::WResource

  def initialize(img, x, y, w, h)
    super()
    @img = img
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def handleRequest(request, response)
    response.mimeType = "image/png"
    @img.generate(@x, @y, @w, @h, response.out)
  end
end

class MandelbrotImage < Wt::WVirtualImage

  def initialize( width, height, virtualWidth, virtualHeight,
                  bx1, by1, bx2, by2,
                  parent )
    super(width, height, virtualWidth, virtualHeight, 256, parent)
    @bx1 = bx1 
    @by1 = by1
    @bwidth = bx2 - bx1
    @bheight = by2 - by1
    @maxDepth = 50
    @bailOut2 = 30*30
    enableDragging
    redrawAll
    scroll(width*2, virtualHeight/2 - height)
  end

  def zoomIn
    resizeImage(imageWidth * 2, imageHeight * 2)
  
    scrollTo( currentTopLeftX * 2 + viewPortWidth / 2,
              currentTopLeftY * 2 + viewPortHeight / 2 )
  end

  def zoomOut
    puts "viewPortWidth %d imageWidth %d viewPortHeight %d imageHeight %d" % [viewPortWidth, imageWidth, viewPortHeight, imageHeight]
    puts "resizeImage(%d, %d)" %  [ [viewPortWidth, imageWidth / 2].max, [viewPortHeight, imageHeight / 2].max ]
    Wt::Internal::setDebug Wt::WtDebugChannel::WTDB_VIRTUAL
    scrollTo( currentTopLeftX / 2 - viewPortWidth / 4,
              currentTopLeftY / 2 - viewPortWidth / 4 )
    resizeImage(  [viewPortWidth, imageWidth / 2].max,
                  [viewPortHeight, imageHeight / 2].max )
  
  end

  def render(x, y, w, h)
    puts "render(%d, %d, %d, %d)" % [x, y, w, h]
    return MandelbrotResource.new(self, x, y, w, h)
  end

  def generate(x, y, w, h, out)
    if w == 0 || h == 0
      return
    end

    im = GD::Image.newTrueColor(w, h)

    puts "rendering: (%s,%s) (%s,%s)" % [x, y, x+w, y+h]
  
    for i in 0...w
      for j in 0...h
        bx = convertPixelX(x + i)
        by = convertPixelY(y + j)
        d = calcPixel(bx, by)
        # puts("calcPixel(%f, %f) %f" % [bx, by, d])
  
        lowr = 100
  
        if d == @maxDepth
          r = g = b = 0
        else
          r = lowr + ((d * (255-lowr)) / @maxDepth)
          g = 0 + ((d * 255) / @maxDepth)
          b = 0
        end
        # puts "setPixel( #{i}, #{j}) r: #{r} g: #{g} b: #{b}"
        im.setPixel(i, j, im.colorAllocate(r.to_i, g.to_i, b.to_i))
      end
    end

    data = im.pngStr  
    out.write(data)
    im.destroy
  end

  def convertPixelX(x)
    # puts "#{@bx1} + ((#{x.to_f}) / #{imageWidth} * #{@bwidth})"
    return @bx1 + ((x.to_f) / imageWidth * @bwidth)
  end

  def convertPixelY(y)
    # puts "#{@by1} + ((#{y.to_f}) / #{imageHeight} * #{@bheight})"
    return @by1 + ((y.to_f) / imageHeight * @bheight)
  end

  def currentX1
    return convertPixelX(currentTopLeftX)
  end

  def currentY1
    return convertPixelY(currentTopLeftY)
  end

  def currentX2
    return convertPixelX(currentBottomRightX)
  end

  def currentY2
    return convertPixelY(currentBottomRightY)
  end

  def calcPixel(x, y)
    x1 = x
    y1 = y
  
    for i in 0...@maxDepth
      xs = x1 * x1
      ys = y1 * y1
      x2 = xs - ys + x
      y2 = x1 * y1 * 2 + y
      x1 = x2
      y1 = y2
  
      z = xs + ys
  
      if xs + ys > @bailOut2
        return i + 1 - Math.log(Math.log(Math.sqrt(z))) / Math.log(2.0)
      end
    end
  
    return @maxDepth
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
