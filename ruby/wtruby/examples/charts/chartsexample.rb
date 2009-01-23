#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'chartconfig.rb'
require 'csvutil.rb'
require 'panellist.rb'

module ChartsUtil
  # Read the model from a CSV file
  def readCsvFile(fname)
    model = Wt::WStandardItemModel.new(0, 0, self)
    begin
      f = File.open(fname, "r")
    rescue
      error = tr("error-missing-data ")
      error += fname
      Wt::WText.new(error, $wApp.root)
      return nil
    end

    readFromCsv(f, model)
    return model
  end
end

#
#  chartsexample Charts example
#
# An application that demonstrates various aspects of the charting lib.
#
class ChartsExample < Wt::WContainerWidget

  # Constructor.
  #
  def initialize(root)
    super(root)
    Wt::WText.new(tr("introduction"), root)
  
    CategoryExample.new(self)
    TimeSeriesExample.new(self)
    ScatterPlotExample.new(self)
    # PieExample.new(self)
  end
end

  # Creates the category chart example
class CategoryExample < Wt::WContainerWidget
  include ChartsUtil

  def initialize(parent)
    super(parent)
    Wt::WText.new(tr("category chart"), self)
  
    model = readCsvFile("category.csv")
  
    if !model
      return
    end

    #
    # If we have JavaScript, show an Ext table view that allows editing
    # of the model.
    #
    if $wApp.environment.javaScript
      w = Wt::WContainerWidget.new(self)
      table = Wt::Ext::TableView.new(w)
      table.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)
      table.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
      table.resize(Wt::WLength.new(500), Wt::WLength.new(175))
      table.model = model
      table.autoExpandColumn = 0
  
      table.setEditor(0, Wt::Ext::LineEdit.new)
  
      for i in 1...model.columnCount
        nf = Wt::Ext::NumberField.new
        table.setEditor(i, nf)
      end
    end

    #
    # Create the category chart.
    #
    chart = Wt::Chart::WCartesianChart.new(self)
    chart.model = model;        # set the model
    chart.xSeriesColumn = 0;    # set the column that holds the categories
    chart.legendEnabled = true; # enable the legend
  
    # Provide space for the X and Y axis and title. 
    chart.setPlotAreaPadding(100, Wt::Left)
    chart.setPlotAreaPadding(50, Wt::Top | Wt::Bottom)
  
    chart.axis(Wt::Chart::YAxis).setBreak(70, 110)
  
    #
    # Add all (but first) column as bar series
    #
    for i in 1...model.columnCount
      s = Wt::Chart::WDataSeries.new(i, Wt::Chart::BarSeries)
      chart.addSeries(s)
    end
  
    chart.resize(Wt::WLength.new(800), Wt::WLength.new(400)) # Wt::WPaintedWidget must be given explicit size
  
    chart.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)        # add margin vertically
    chart.setMargin(Wt::WLength.new, Wt::Left | Wt::Right) # center horizontally
  
    ChartConfig.new(chart, self)
  end
end

  # Creates the time series scatterplot example
class TimeSeriesExample < Wt::WContainerWidget
  include ChartsUtil

  def initialize(parent)
    super(parent)
    Wt::WText.new(tr("scatter plot"), self)
  
    model = readCsvFile("timeseries.csv")
  
    if !model
      return
    end
  
    #
    # Parse the first column as dates
    #
    for i in 0...model.rowCount
      s = model.data(i, 0).value
      d = Wt::WDate.fromString(s, "dd/MM/yy")
      model.setData(i, 0, Boost::Any.new(d))
      end
  
    #
    # Create the scatter plot.
    #
    chart = Wt::Chart::WCartesianChart.new(self)
    chart.model = model;        # set the model
    chart.xSeriesColumn = 0;    # set the column that holds the X data
    chart.legendEnabled = true; # enable the legend
  
    chart.type = Wt::Chart::ScatterPlot            # set type to ScatterPlot
    chart.axis(Wt::Chart::XAxis).scale = Wt::Chart::DateScale # set scale of X axis to DateScale
  
    # Provide space for the X and Y axis and title. 
    chart.setPlotAreaPadding(100, Wt::Left)
    chart.setPlotAreaPadding(50, Wt::Top | Wt::Bottom)
  
  #
    # Add first two columns as line series
    #
    for i in 1...3
      s = Wt::Chart::WDataSeries.new(i, Wt::Chart::LineSeries)
      chart.addSeries(s)
    end
  
    chart.resize(Wt::WLength.new(800), Wt::WLength.new(400)) # Wt::WPaintedWidget must be given explicit size
  
    chart.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)        # add margin vertically
    chart.setMargin(Wt::WLength.new, Wt::Left | Wt::Right) # center horizontally
  
    ChartConfig.new(chart, self)
  end
end

class ScatterPlotExample < Wt::WContainerWidget
  include ChartsUtil

  def initialize(parent)
    super(parent)
    Wt::WText.new(tr("scatter plot 2"), self)
  
    model = Wt::WStandardItemModel.new(100, 2, self)
    model.setHeaderData(0, Boost::Any.new("X"))
    model.setHeaderData(1, Boost::Any.new("Y = sin(X)"))
  
    for i in 0...40
      x = (i.to_f - 20) / 4
  
      model.setData(i, 0, Boost::Any.new(x))
      model.setData(i, 1, Boost::Any.new(Math.sin(x)))
    end
  
    #
    # Create the scatter plot.
    #
    chart = Wt::Chart::WCartesianChart.new(self)
    chart.model = model        # set the model
    chart.xSeriesColumn = 0    # set the column that holds the X data
    chart.legendEnabled = true # enable the legend
  
    chart.type = Wt::Chart::ScatterPlot   # set type to ScatterPlot
  
    # Typically, for mathematical functions, you want the axes to cross
    # at the 0 mark:
    chart.axis(Wt::Chart::XAxis).location = Wt::Chart::ZeroValue
    chart.axis(Wt::Chart::YAxis).location = Wt::Chart::ZeroValue
  
    # Provide space for the X and Y axis and title. 
    chart.setPlotAreaPadding(100, Wt::Left)
    chart.setPlotAreaPadding(50, Wt::Top | Wt::Bottom)
  
    # Add the two curves
    chart.addSeries(Wt::Chart::WDataSeries.new(1, Wt::Chart::CurveSeries))
  
    chart.resize(Wt::WLength.new(800), Wt::WLength.new(300)) # Wt::WPaintedWidget must be given explicit size
  
    chart.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)        # add margin vertically
    chart.setMargin(Wt::WLength.new, Wt::Left | Wt::Right) # center horizontally
  
    config = ChartConfig.new(chart, self)
    config.valueFill = Wt::Chart::ZeroValueFill
  end
end

  # Creates the pie chart example
class PieExample < Wt::WContainerWidget
  include ChartsUtil

  def initialize(parent)
    Wt::WText.new(tr("pie chart"), self)
  
    model = readCsvFile("pie.csv")
  
    if !model
      return
    end
  
    #
    # If we have JavaScript, show an Ext table view that allows editing
    # of the model.
    #
    if $wApp.environment.javaScript
      w = Wt::WContainerWidget.new(self)
      table = Wt::Ext::TableView.new(w)
      table.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)
      table.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
      table.resize(Wt::WLength.new(300), Wt::WLength.new(175))
      table.model = model
      table.autoExpandColumn = 0
  
      table.setEditor(0, Wt::Ext::LineEdit.new)
  
      for i in 1...model.columnCount
        table.setEditor(i, Wt::Ext::NumberField.new)
      end
    end

    #
    # Create the pie chart.
    #
    chart = Wt::Chart::WPieChart.new(self)
    chart.model = model       # set the model
    chart.labelsColumn = 0    # set the column that holds the labels
    chart.dataColumn = 1      # set the column that holds the data
  
    # configure location and type of labels
    chart.displayLabels = Wt::Chart::Outside | Wt::Chart::TextLabel | Wt::Chart::TextPercentage
  
    # enable a 3D effect
    chart.setPerspectiveEnabled(true, 0.2)
  
    # explode the first item
    chart.setExplode(0, 0.3)
  
    chart.resize(Wt::WLength.new(800), Wt::WLength.new(300)) # Wt::WPaintedWidget must be given explicit size
  
    chart.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)        # add margin vertically
    chart.setMargin(Wt::WLength.new, Wt::Left | Wt::Right) # center horizontally
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
