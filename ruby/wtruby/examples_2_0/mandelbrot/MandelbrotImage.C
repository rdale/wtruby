/*
 * Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
 *
 * See the LICENSE file for terms of use.
 */

#include <math.h>
#include <stdio.h>
#include <fstream>
#include <iostream>
#include "gd.h"
#ifdef WIN32
#include <io.h>
#endif

#include <Wt/WResource>
#include <Wt/WImage>

#include "MandelbrotImage.h"

namespace {
  class MandelbrotResource : public WResource
  {
  public:
    MandelbrotResource(MandelbrotImage *img,
		       long long x, long long y, int w, int h)
      : img_(img),
	x_(x), y_(y), w_(w), h_(h)
    {
      /*
       * This resource is not entirely reentrant, since WVirtualImage
       * may delete it at any time.
       */
      //setReentrant(true);
    }

    const std::string resourceMimeType() const { return "image/png"; }

    bool streamResourceData(std::ostream& stream,
			    const ArgumentMap& arguments) {
      img_->generate(x_, y_, w_, h_, stream);
      return true;
    }

  private:
    MandelbrotImage *img_;
    long long x_, y_;
    int w_, h_;
  };
}

MandelbrotImage::MandelbrotImage(int width, int height,
				 long long virtualWidth,
				 long long virtualHeight,
				 double bx1, double by1,
				 double bx2, double by2,
				 WContainerWidget *parent)
  : WVirtualImage(width, height, virtualWidth, virtualHeight, 256, parent),
    bx1_(bx1), by1_(by1),
    bwidth_(bx2 - bx1), bheight_(by2 - by1),
    maxDepth_(50),
    bailOut2_(30*30)
{
  enableDragging();
  redrawAll();
  scroll(width*2, virtualHeight/2 - height);
}

void MandelbrotImage::zoomIn()
{
  resizeImage(imageWidth() * 2, imageHeight() * 2);

  scrollTo(currentTopLeftX() * 2 + viewPortWidth()/2,
	   currentTopLeftY() * 2 + viewPortHeight()/2);
}

void MandelbrotImage::zoomOut()
{
  resizeImage(std::max((long long)viewPortWidth(), imageWidth() / 2),
	      std::max((long long)viewPortHeight(), imageHeight() / 2));

  scrollTo(currentTopLeftX() / 2 - viewPortWidth()/4,
	   currentTopLeftY() / 2 - viewPortWidth()/4);
}

WResource *MandelbrotImage::render(long long x, long long y, int w, int h)
{
  return new MandelbrotResource(this, x, y, w, h);
}

void MandelbrotImage::generate(long long x, long long y, int w, int h,
			       std::ostream& out)
{
  gdImagePtr im = gdImageCreateTrueColor(w, h);

  std::cerr << "rendering: (" << x << "," << y << ") (" 
	    << x+w << "," << y+h << ")" << std::endl;

  for (int i = 0; i < w; ++i)
    for (int j = 0; j < h; ++j) {
      double bx = convertPixelX(x + i);
      double by = convertPixelY(y + j);
      double d = calcPixel(bx, by);

      int lowr = 100;

      int r, g, b;
      if (d == maxDepth_)
	r = g = b = 0;
      else {
	r = lowr + (int)((d * (255-lowr))/maxDepth_);
	g = 0 + (int)((d * 255)/maxDepth_);
	b = 0;
      }

      gdImageSetPixel(im, i, j, gdImageColorAllocate(im, r, g, b));
    }

  int size;
  char *data = (char *) gdImagePngPtr(im, &size);

  out.write(data, size);

  gdFree(data);
  gdImageDestroy(im);
}

double MandelbrotImage::convertPixelX(long long x) const
{
  return bx1_ + ((double) (x) / imageWidth() * bwidth_);
}

double MandelbrotImage::convertPixelY(long long y) const
{
  return by1_ + ((double) (y) / imageHeight() * bheight_);
}

double MandelbrotImage::currentX1() const
{
  return convertPixelX(currentTopLeftX());
}

double MandelbrotImage::currentY1() const
{
  return convertPixelY(currentTopLeftY());
}

double MandelbrotImage::currentX2() const
{
  return convertPixelX(currentBottomRightX());
}

double MandelbrotImage::currentY2() const
{
  return convertPixelY(currentBottomRightY());
}

double MandelbrotImage::calcPixel(double x, double y)
{
  double x1 = x;
  double y1 = y;

  for (int i = 0; i < maxDepth_; ++i) {
    double xs = x1 * x1;
    double ys = y1 * y1;
    double x2 = xs - ys + x;
    double y2 = x1 * y1 * 2 + y;
    x1 = x2;
    y1 = y2;

    double z = xs + ys;

    if (xs + ys > bailOut2_)
      return (double)i + 1 - log(log(sqrt(z)))/log(2.0);
  }

  return maxDepth_;
}
