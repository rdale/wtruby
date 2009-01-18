#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

class TreeViewExample < Wt::WContainerWidget

  @@weatherIcons = [
    "sun01.png",
    "cloudy01.png",
    "w_cloud.png",
    "rain.png",
    "storm.png",
    "snow.png" ]

  Sun = 0
  SunCloud = 1
  Cloud = 2
  Rain = 3
  Storm = 4
  Snow = 5

  def initialize(useInternalPath, parent)
    super(parent)
    @useInternalPath = useInternalPath                                 
    Wt::WText.new(tr("treeview-introduction"), self)
  
    #
    # Setup a model.
    #
    # We use the standard item model, which is a general model
    # suitable for hierarchical (tree-like) data, but stores all data
    # in memory.
    #
    @model = Wt::WStandardItemModel.new(0, 4, self)

    #
    # Headers ...
    #
    @model.setHeaderData(0, Wt::Horizontal, Boost::Any.new("Places"))
    @model.setHeaderData(1, Wt::Horizontal, Boost::Any.new("Weather"))
    @model.setHeaderData(2, Wt::Horizontal, Boost::Any.new("Drink"))
    @model.setHeaderData(3, Wt::Horizontal, Boost::Any.new("Visited"))
  
    #
    # ... and data
    #
    @model.appendRow(continent = continentItem("Europe"))
  
    continent.appendRow(country = countryItem("Belgium", "be"))
    country.appendRow(cityItems("Brussels", Rain, "Beer", true))
    country.appendRow(cityItems("Leuven", Rain, "Beer", true))
  
    @belgium = country
  
    continent.appendRow(country = countryItem("France", "fr"))
    country.appendRow(cityItems("Paris", Cloud, "Wine", true))
    country.appendRow(cityItems("Bordeaux", SunCloud, "Bordeaux wine", false))
  
    continent.appendRow(country = countryItem("Spain", "sp"))
    country.appendRow(cityItems("Barcelona", Sun, "Cava", true))
    country.appendRow(cityItems("Madrid", Sun, "San Miguel", false))
  
    @model.appendRow(continent = continentItem("Africa"))
  
    continent.appendRow(country = countryItem("Morocco (المغرب)", "ma"))
    country.appendRow(cityItems("Casablanca", Sun, "Tea", false))
  
    #
    # Now create the view
    #
    @treeView = Wt::WTreeView.new(self)
    @treeView.alternatingRowColors = !@treeView.alternatingRowColors
    @treeView.rowHeight = Wt::WLength.new(30)
    @treeView.model = @model
    #@treeView.sortingEnabled = false
    @treeView.selectionMode = Wt::NoSelection
    @treeView.resize(Wt::WLength.new(600), Wt::WLength.new(300))

    @treeView.setColumnWidth(1, Wt::WLength.new(100))
    @treeView.setColumnAlignment(1, Wt::AlignCenter)
    @treeView.setColumnWidth(3, Wt::WLength.new(100))
    @treeView.setColumnAlignment(3, Wt::AlignCenter)

    #
    # Expand the first (and single) top level node
    #
    @treeView.setExpanded(@model.index(0, 0), true)
  
    #
    # Setup some buttons to manipulate the view and the model.
    #
    wc = Wt::WContainerWidget.new(self)
  
    b = Wt::WPushButton.new("Toggle row height", wc)
    b.clicked.connect(SLOT(self, :toggleRowHeight))
    b.toolTip = "Toggles row height between 30px and 25px"
    
    b = Wt::WPushButton.new("Toggle stripes", wc)
    b.clicked.connect(SLOT(self, :toggleStripes))
    b.toolTip = "Toggle alternating row colors"
    
    b = Wt::WPushButton.new("Toggle root", wc)
    b.clicked.connect(SLOT(self, :toggleRoot))
    b.toolTip = "Toggles root item between all and the first continent."
    
    b = Wt::WPushButton.new("Add rows", wc)
    b.clicked.connect(SLOT(self, :addRows))
    b.toolTip = "Adds some cities to Belgium"
  end

  def continentItem(continent)
    return Wt::WStandardItem.new(continent)
  end

  def countryItem(country, code)
    result = Wt::WStandardItem.new(country)
    result.icon = "icons/flag_" + code + ".png"
    return result
  end

  def cityItems(city, weather, drink, visited)
    result = []
    # column 0: country
    item = Wt::WStandardItem.new(city)
    result.push(item)
  
    # column 1: weather
    item = Wt::WStandardItem.new
    item.icon = "icons/" + @@weatherIcons[weather]
    result.push(item)
  
    # column 2: drink
    item = Wt::WStandardItem.new(drink)
    if @useInternalPath
      item.internalPath = "/drinks/" + drink
    end
    result.push(item)
  
    # column 3: visited
    item = Wt::WStandardItem.new
    item.checkable = true
    item.checked = visited
    result.push(item)
  
    return result
  end

  def toggleRowHeight
    if @treeView.rowHeight == Wt::WLength.new(30)
      @treeView.rowHeight = Wt::WLength.new(25)
    else
      @treeView.rowHeight = Wt::WLength.new(30)
    end
  end

  def toggleStripes
    @treeView.alternatingRowColors = !@treeView.alternatingRowColors
  end

  def toggleRoot
    if @treeView.rootIndex == Wt::WModelIndex.new
      @treeView.setRootIndex(@model.index(0, 0))
    else
      @treeView.rootIndex = Wt::WModelIndex.new
    end
  end

  def addRows
    for i in 0...5
      cityName = "City " + (@belgium.rowCount.to_i + 1).to_s
    end
    @belgium.appendRow(cityItems(cityName, Storm, "Juice", false))
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
