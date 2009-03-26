#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#

$: << '../painting'
require 'paintexample.rb'

class GraphicsWidgets < ControlsWidget

  def initialize(ed)
    super(ed, false)
    topic("WPaintedWidget", self)
    Wt::WText.new(tr("graphics-intro"), self)
    PaintExample.new(self)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
