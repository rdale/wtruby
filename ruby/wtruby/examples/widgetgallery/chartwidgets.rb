#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

$: << '../charts'
require 'chartsexample.rb'

class ChartWidgets < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("charts-intro"), self)
    Wt::WText.new(tr("charts-introduction"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("Category Charts",
                  deferCreate(:category, self))
    menu.addItem("Scatter Plots",
                  deferCreate(:scatterplot, self))
    menu.addItem("Pie Charts",
                  deferCreate(:pie, self))
  end

  def category
    retval = Wt::WContainerWidget.new(nil)
    topic("Chart::WCartesianChart", retval)
    CategoryExample.new(retval)
    return retval
  end

  def scatterplot
    retval = Wt::WContainerWidget.new(nil)
    topic("Chart::WCartesianChart", retval)
    TimeSeriesExample.new(retval)
    ScatterPlotExample.new(retval)
    return retval
  end

  def pie
    retval = Wt::WContainerWidget.new(nil)
    topic("Chart::WPieChart", retval)
    PieExample.new(retval)
    return retval
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
