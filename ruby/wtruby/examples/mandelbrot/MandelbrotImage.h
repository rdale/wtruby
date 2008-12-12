// This may look like C code, but it's really -*- C++ -*-
/*
 * Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
 *
 * See the LICENSE file for terms of use.
 */

#ifndef MANDELBROT_IMAGE_H_
#define MANDELBROT_IMAGE_H_

#include <Wt/WVirtualImage>

using namespace Wt;

class MandelbrotImage : public WVirtualImage
{
public:
  MandelbrotImage(int width, int height,
		  long long virtualWidth, long long virtualHeight,
		  double bx1, double by1,
		  double bx2, double by2,
		  WContainerWidget *parent = 0);

  void zoomIn();
  void zoomOut();

  void generate(long long x, long long y, int w, int h, std::ostream& out);

  double currentX1() const;
  double currentY1() const;
  double currentX2() const;
  double currentY2() const;

private:
  double bx1_, by1_, bwidth_, bheight_;
  int maxDepth_;
  double bailOut2_;

  virtual WResource *render(long long x, long long y, int w, int h);
  double calcPixel(double x, double y);

  double convertPixelX(long long x) const;
  double convertPixelY(long long y) const;
};

#endif // MANDELBROT_IMAGE_H_
