#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#  chartsexample
#
# A class that allows configuration of a cartesian chart.
#
# This widget provides forms for configuring chart, series, and axis properties
# and manipulates the chart according to user settings.
#
# This widget is part of the Wt charts example.
#
class ChartConfig < Wt::WContainerWidget

  SeriesControl = Struct.new( "SeriesControl", 
                              :enabledEdit, 
                              :typeEdit, 
                              :markerEdit, 
                              :axisEdit, 
                              :legendEdit, 
                              :labelsEdit )

  AxisControl = Struct.new( "AxisControl", 
                            :visibleEdit, 
                            :scaleEdit, 
                            :autoEdit, 
                            :minimumEdit, 
                            :maximumEdit, 
                            :gridLinesEdit, 
                            :labelAngleEdit )

  def addHeader(t, value)
    t.elementAt(0, t.numColumns).addWidget(Wt::WText.new(value))
  end

  def addEntry(model, value)
    model.insertRows(model.rowCount, 1)
    model.setData(model.rowCount - 1, 0, Boost::Any.new(value))
  end


  # Constructor.
  #  
  # Struct that holds the controls for one series
  # Controls for series
  # Struct that holds the controls for one axis
  # Controls for axes
  def initialize(chart, parent)
    super(parent)
    @chart = chart
    @fill = Wt::Chart::MinimumValueFill
    list = PanelList.new(self)
    @seriesControls = []
    @axisControls = []

    sizeValidator = Wt::WIntValidator.new(200, 2000, self)
    sizeValidator.mandatory = true
  
    anyNumberValidator = Wt::WDoubleValidator.new(self)
    anyNumberValidator.mandatory = true
  
    angleValidator = Wt::WDoubleValidator.new(-90, 90, self)
    angleValidator.mandatory = true
  
    # ---- Chart properties ----
  
    orientation = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(orientation, "Vertical")
    addEntry(orientation, "Horizontal")
  
    chartConfig = Wt::WTable.new
    chartConfig.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
  
    row = 0
    chartConfig.elementAt(row, 0).addWidget(Wt::WText.new("Title:"))
    @titleEdit = Wt::WLineEdit.new(chartConfig.elementAt(row, 1))
    connectSignals(@titleEdit)
    row += 1
  
    chartConfig.elementAt(row, 0).addWidget(Wt::WText.new("Width:"))
    @chartWidthEdit = Wt::WLineEdit.new(chartConfig.elementAt(row, 1))
    @chartWidthEdit.text = @chart.width.value.to_s
    @chartWidthEdit.validator = sizeValidator
    @chartWidthEdit.maxLength = 4
    connectSignals(@chartWidthEdit)
    row += 1
  
    chartConfig.elementAt(row, 0).addWidget(Wt::WText.new("Height:"))
    @chartHeightEdit = Wt::WLineEdit.new(chartConfig.elementAt(row, 1))
    @chartHeightEdit.text = @chart.height.value.to_s
    @chartHeightEdit.validator = sizeValidator
    @chartHeightEdit.maxLength = 4
    connectSignals(@chartHeightEdit)
    row += 1
  
    chartConfig.elementAt(row, 0).addWidget(Wt::WText.new("Orientation:"))
    @chartOrientationEdit = Wt::WComboBox.new(chartConfig.elementAt(row, 1))
    @chartOrientationEdit.model = orientation
    connectSignals(@chartOrientationEdit)
    row += 1
  
    for i in 0...chartConfig.numRows
      chartConfig.elementAt(i, 0).styleClass = "tdhead"
      chartConfig.elementAt(i, 1).styleClass = "tddata"
    end
  
    p = list.addWidget("Chart properties", chartConfig)
    p.setMargin(Wt::WLength.new(100), Wt::Left | Wt::Right)
    p.setMargin(Wt::WLength.new(20), Wt::Top | Wt::Bottom)
  
    if @chart.isLegendEnabled
      @chart.setPlotAreaPadding(200, Wt::Right)
    end
  
    # ---- Series properties ----
  
    types = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(types, "Points")
    addEntry(types, "Line")
    addEntry(types, "Curve")
    addEntry(types, "Bar")
    addEntry(types, "Line Area")
    addEntry(types, "Curve Area")
    addEntry(types, "Stacked Bar")
    addEntry(types, "Stacked Line Area")
    addEntry(types, "Stacked Curve Area")
  
    markers = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(markers, "None")
    addEntry(markers, "Square")
    addEntry(markers, "Circle")
    addEntry(markers, "Cross")
    addEntry(markers, "X cross")
    addEntry(markers, "Triangle")
  
    axes = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(axes, "1st Y axis")
    addEntry(axes, "2nd Y axis")
  
    labels = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(labels, "None")
    addEntry(labels, "X")
    addEntry(labels, "Y")
    addEntry(labels, "X: Y")
  
    seriesConfig = Wt::WTable.new
    seriesConfig.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
  
    addHeader(seriesConfig, "Name")
    addHeader(seriesConfig, "Enabled")
    addHeader(seriesConfig, "Type")
    addHeader(seriesConfig, "Marker")
    addHeader(seriesConfig, "Y axis")
    addHeader(seriesConfig, "Legend")
    addHeader(seriesConfig, "Value labels")
  
    seriesConfig.rowAt(0).styleClass = "trhead"
  
    for j in 1...chart.model.columnCount
      sc = SeriesControl.new
  
      Wt::WText.new(chart.model.headerData(j).value, seriesConfig.elementAt(j, 0))
  
      sc.enabledEdit = Wt::WCheckBox.new(seriesConfig.elementAt(j, 1))
      connectSignals(sc.enabledEdit)
  
      sc.typeEdit = Wt::WComboBox.new(seriesConfig.elementAt(j, 2))
      sc.typeEdit.model = types
      connectSignals(sc.typeEdit)
  
      sc.markerEdit = Wt::WComboBox.new(seriesConfig.elementAt(j, 3))
      sc.markerEdit.model = markers
      connectSignals(sc.markerEdit)
  
      sc.axisEdit = Wt::WComboBox.new(seriesConfig.elementAt(j, 4))
      sc.axisEdit.model = axes
      connectSignals(sc.axisEdit)
  
      sc.legendEdit = Wt::WCheckBox.new(seriesConfig.elementAt(j, 5))
      connectSignals(sc.legendEdit)
  
      sc.labelsEdit = Wt::WComboBox.new(seriesConfig.elementAt(j, 6))
      sc.labelsEdit.model = labels
      connectSignals(sc.labelsEdit)
  
      si = chart.seriesIndexOf(j)
  
      if si != -1
        sc.enabledEdit.setChecked
        s = @chart.series(j)
        case s.type
        when Wt::Chart::PointSeries:
          sc.typeEdit.currentIndex = 0
        when Wt::Chart::LineSeries:
          sc.typeEdit.currentIndex = (s.fillRange != Wt::Chart::NoFill ? (s.isStacked ? 7 : 4) : 1)
        when Wt::Chart::CurveSeries:
          sc.typeEdit.currentIndex = (s.fillRange != Wt::Chart::NoFill ? (s.isStacked ? 8 : 5) : 2)
        when Wt::Chart::BarSeries:
          sc.typeEdit.currentIndex = s.isStacked ? 6 : 3
        end
  
        sc.markerEdit.currentIndex = s.marker
        sc.legendEdit.checked = s.isLegendEnabled
      end
  
      @seriesControls << sc
  
      seriesConfig.rowAt(j).styleClass = "trdata"
    end
  
    p = list.addWidget("Series properties", seriesConfig)
    p.expand
    p.setMargin(Wt::WLength.new(100), Wt::Left | Wt::Right)
    p.setMargin(Wt::WLength.new(20), Wt::Top | Wt::Bottom)
  
    # ---- Axis properties ----
  
    yScales = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(yScales, "Linear scale")
    addEntry(yScales, "Log scale")
  
    xScales = Wt::WStandardItemModel.new(0, 1, self)
    addEntry(xScales, "Categories")
    addEntry(xScales, "Linear scale")
    addEntry(xScales, "Log scale")
    addEntry(xScales, "Date scale")
  
    axisConfig = Wt::WTable.new
    axisConfig.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
  
    addHeader(axisConfig, "Axis")
    addHeader(axisConfig, "Visible")
    addHeader(axisConfig, "Scale")
    addHeader(axisConfig, "Automatic")
    addHeader(axisConfig, "Minimum")
    addHeader(axisConfig, "Maximum")
    addHeader(axisConfig, "Gridlines")
    addHeader(axisConfig, "Label angle")
  
    axisConfig.rowAt(0).styleClass = "trhead"
  
    for i in 0...3
      axisName = ["X axis", "1st Y axis", "2nd Y axis"]
      j = i + 1
  
      axis = @chart.axis(i)
      sc = AxisControl.new
  
      Wt::WText.new(axisName[i], axisConfig.elementAt(j, 0))
  
      sc.visibleEdit = Wt::WCheckBox.new(axisConfig.elementAt(j, 1))
      sc.visibleEdit.checked = axis.isVisible
      connectSignals(sc.visibleEdit)
  
      sc.scaleEdit = Wt::WComboBox.new(axisConfig.elementAt(j, 2))
      if axis.scale == Wt::Chart::CategoryScale
        sc.scaleEdit.addItem("Category scale")
      else
        if axis.id == Wt::Chart::XAxis
          sc.scaleEdit.model = xScales
          sc.scaleEdit.currentIndex = axis.scale
        else
          sc.scaleEdit.model = yScales
          sc.scaleEdit.currentIndex = axis.scale - 1
        end
      end
      connectSignals(sc.scaleEdit)
  
      autoValues = axis.minimum == Wt::Chart::WAxis::AUTO_MINIMUM && axis.maximum == Wt::Chart::WAxis::AUTO_MAXIMUM
  
      sc.minimumEdit = Wt::WLineEdit.new(axisConfig.elementAt(j, 4))
      sc.minimumEdit.text = axis.minimum.to_s
      sc.minimumEdit.validator = anyNumberValidator
      sc.minimumEdit.enabled = !autoValues
      connectSignals(sc.minimumEdit)
  
      sc.maximumEdit = Wt::WLineEdit.new(axisConfig.elementAt(j, 5))
      sc.maximumEdit.text = axis.maximum.to_s
      sc.maximumEdit.validator = anyNumberValidator
      sc.maximumEdit.enabled = !autoValues
      connectSignals(sc.maximumEdit)
  
      sc.autoEdit = Wt::WCheckBox.new(axisConfig.elementAt(j, 3))
      sc.autoEdit.checked = autoValues
      connectSignals(sc.autoEdit)
      sc.autoEdit.checked.connect(SLOT(sc.maximumEdit, :disable))
      sc.autoEdit.unChecked.connect(SLOT(sc.maximumEdit, :enable))
      sc.autoEdit.checked.connect(SLOT(sc.minimumEdit, :disable))
      sc.autoEdit.unChecked.connect(SLOT(sc.minimumEdit, :enable))
  
      sc.gridLinesEdit = Wt::WCheckBox.new(axisConfig.elementAt(j, 6))
      connectSignals(sc.gridLinesEdit)
  
      sc.labelAngleEdit = Wt::WLineEdit.new(axisConfig.elementAt(j, 7))
      sc.labelAngleEdit.text = "0"
      sc.labelAngleEdit.validator = angleValidator
      connectSignals(sc.labelAngleEdit)
  
      axisConfig.rowAt(j).styleClass = "trdata"
  
      @axisControls << sc
    end
  
    p = list.addWidget("Axis properties", axisConfig)
    p.setMargin(Wt::WLength.new(100), Wt::Left | Wt::Right)
    p.setMargin(Wt::WLength.new(20), Wt::Top | Wt::Bottom)
  
    #
    # If we do not have JavaScript, then add a button to reflect changes to
    # the chart.
    #
    if !Wt::WApplication.instance.environment.javaScript
      b = Wt::WPushButton.new(self)
      b.text = "Update chart"
      b.inline = false; # so we can add margin to center horizontally
      b.setMargin(Wt::WLength.new, Wt::Left | Wt::Right)
      b.clicked.connect(SLOT(self, :update))
    end
  end

  def valueFill=(fill)
    @fill = fill
  end

  def update
    haveLegend = false
    series = []
  
    for i in 1...@chart.model.columnCount
      sc = @seriesControls[i-1]
  
      if sc.enabledEdit.isChecked
        s = Wt::Chart::WDataSeries.new(i)
  
        case sc.typeEdit.currentIndex
        when 0:
          s.type = Wt::Chart::PointSeries
          if sc.markerEdit.currentIndex == 0
            sc.markerEdit.currentIndex = 1
          end
        when 1:
          s.type = Wt::Chart::LineSeries
        when 2:
          s.type = Wt::Chart::CurveSeries
        when 3:
          s.type = Wt::Chart::BarSeries
        when 4:
          s.type = Wt::Chart::LineSeries
          s.fillRange = @fill
        when 5:
          s.type = Wt::Chart::CurveSeries
          s.fillRange = @fill
        when 6:
          s.type = Wt::Chart::BarSeries
          s.stacked = true
        when 7:
          s.type = Wt::Chart::LineSeries
          s.fillRange = @fill
          s.stacked = true
        when 8:
          s.type = Wt::Chart::CurveSeries
          s.fillRange = @fill
          s.stacked = true
        end
  
        s.marker = sc.markerEdit.currentIndex
  
        if sc.axisEdit.currentIndex == 1
          s.bindToAxis(Wt::Chart::Y2Axis)
        end
  
        if sc.legendEdit.isChecked
          s.legendEnabled = true
          haveLegend = true
        else
          s.legendEnabled = false
        end

        case sc.labelsEdit.currentIndex
        when 1:
          s.labelsEnabled = Wt::Chart::XAxis
        when 2:
          s.labelsEnabled = Wt::Chart::YAxis
        when 3:
          s.labelsEnabled = Wt::Chart::XAxis
          s.labelsEnabled = Wt::Chart::YAxis
        end
  
        series << s
      end
    end
  
    @chart.series = series
  
    for i in 0...3
      sc = @axisControls[i]
      axis = @chart.axis(i)
  
      axis.visible = sc.visibleEdit.isChecked
  
      if sc.scaleEdit.count != 1
        k = sc.scaleEdit.currentIndex
        if axis.id != Wt::Chart::XAxis
          k += 1
        elsif k == 0
          @chart.type = Wt::Chart::CategoryChart
        else
          @chart.type = Wt::Chart::ScatterPlot
        end
    
        case k
        when 1:
          axis.scale = Wt::Chart::LinearScale
        when 2:
          axis.scale = Wt::Chart::LogScale
        when 3:
          axis.scale = Wt::Chart::DateScale
        end
      end
  
      if sc.autoEdit.isChecked
        axis.setRange(Wt::Chart::WAxis::AUTO_MINIMUM, Wt::Chart::WAxis::AUTO_MAXIMUM)
      elsif validate(sc.minimumEdit) && validate(sc.maximumEdit)
        min = sc.minimumEdit.to_f
        max = sc.maximumEdit.to_f

        if axis.scale == Wt::Chart::LogScale
          if min <= 0
            min = 0.0001
          end
        end
        max = [min, max].max

        axis.setRange(min, max)
      end
  
      if validate(sc.labelAngleEdit)
        angle = sc.labelAngleEdit.text.to_f
        axis.labelAngle = angle
      end
  
      axis.gridLinesEnabled = sc.gridLinesEdit.isChecked
    end
  
    @chart.title = @titleEdit.text
  
    if validate(@chartWidthEdit) && validate(@chartHeightEdit)
      double width, height
      width = @chartWidthEdit.to_f
      height = @chartHeightEdit.to_f
      @chart.resize(width, height)
    end
  
    case @chartOrientationEdit.currentIndex
    when 0:
      @chart.orientation = Wt::Vertical
    when 1:
      @chart.orientation = Wt::Horizontal
    end
  
    @chart.legendEnabled = haveLegend
    @chart.setPlotAreaPadding(haveLegend ? 200 : 40, Wt::Right)
  end

  def validate(w)
    valid = w.validate == Wt::WValidator::Valid
  
    if !Wt::WApplication.instance.environment.javaScript
      w.styleClass = valid ? "" : "Wt-invalid"
      w.toolTip = valid ? "" : "Invalid value"
    end
  
    return valid
  end

  def connectSignals(w)
    w.changed.connect(SLOT(self, :update))
    if w.kind_of?(Wt::WLineEdit)
      w.enterPressed.connect(SLOT(self, :update))
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
