#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class StyleLayout < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("style-layout-intro"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("CSS", css)
    menu.addItem("WBoxLayout", wBoxLayout)
    menu.addItem("WGridLayout", wGridLayout)
    menu.addItem("WBorderLayout", wBorderLayout)
  end

  def css
    return Wt::WText.new(tr("style-and-layout-css"))
  end

  def wBoxLayout
    result = Wt::WContainerWidget.new
    topic("WHBoxLayout", "WVBoxLayout", result)

    Wt::WText.new(tr("layout-WBoxLayout"), result)
    #
    # first hbox
    #
    container = Wt::WContainerWidget.new(result)
    container.styleClass = "yellow-box"
    hbox = Wt::WHBoxLayout.new
    container.layout = hbox

    item = Wt::WText.new(tr("layout-item1"))
    item.styleClass = "green-box"
    hbox.addWidget(item)
    
    item = Wt::WText.new(tr("layout-item2"))
    item.styleClass = "blue-box"
    hbox.addWidget(item)

    Wt::WText.new(tr("layout-WBoxLayout-stretch"), result)

    #
    # second hbox
    #
    container = Wt::WContainerWidget.new(result)
    container.styleClass = "yellow-box"
    hbox = Wt::WHBoxLayout.new
    container.layout = hbox

    item = Wt::WText.new(tr("layout-item1"))
    item.styleClass = "green-box"
    hbox.addWidget(item, 1)
    
    item = Wt::WText.new(tr("layout-item2"))
    item.styleClass = "blue-box"
    hbox.addWidget(item)

    Wt::WText.new(tr("layout-WBoxLayout-vbox"), result)

    #
    # first vbox
    #
    container = Wt::WContainerWidget.new(result)
    container.resize(Wt::WLength.new(150), Wt::WLength.new(150))
    container.styleClass = "yellow-box centered"
    vbox = Wt::WVBoxLayout.new
    container.layout = vbox

    item = Wt::WText.new(tr("layout-item1"))
    item.styleClass = "green-box"
    vbox.addWidget(item)
    
    item = Wt::WText.new(tr("layout-item2"))
    item.styleClass = "blue-box"
    vbox.addWidget(item)

    #
    # second vbox
    #
    container = Wt::WContainerWidget.new(result)
    container.resize(Wt::WLength.new(150), Wt::WLength.new(150))
    container.styleClass = "yellow-box centered"
    vbox = Wt::WVBoxLayout.new
    container.layout = vbox

    item = Wt::WText.new(tr("layout-item1"))
    item.styleClass = "green-box"
    vbox.addWidget(item, 1)
    
    item = Wt::WText.new(tr("layout-item2"))
    item.styleClass = "blue-box"
    vbox.addWidget(item)

    Wt::WText.new(tr("layout-WBoxLayout-nested"), result)

    #
    # nested boxes
    #
    container = Wt::WContainerWidget.new(result)
    container.resize(Wt::WLength.new(200), Wt::WLength.new(200))
    container.styleClass = "yellow-box centered"

    vbox = Wt::WVBoxLayout.new
    container.layout = vbox

    item = Wt::WText.new(tr("layout-item1"))
    item.styleClass = "green-box"
    vbox.addWidget(item, 1)

    hbox = Wt::WHBoxLayout.new
    vbox.addLayout(hbox)

    item = Wt::WText.new(tr("layout-item2"))
    item.styleClass = "green-box"
    hbox.addWidget(item)

    item = Wt::WText.new(tr("layout-item3"))
    item.styleClass = "blue-box"
    hbox.addWidget(item)

    return result
  end

  def wGridLayout
    result = Wt::WContainerWidget.new
    topic("WGridLayout", result)

    Wt::WText.new(tr("layout-WGridLayout"), result)

    container = Wt::WContainerWidget.new(result)
    container.resize(Wt::WLength.new, Wt::WLength.new(400))
    container.styleClass = "yellow-box"
    grid = Wt::WGridLayout.new
    container.layout = grid

    for row in 0...3
      for column in 0...4
        t = Wt::WText.new(tr("grid-item").sub('{1}', row.to_s).sub('{2}', column.to_s))
        if row == 1 || column == 1 || column == 2
          t.styleClass = "blue-box"
        else
          t.styleClass = "green-box"
        end
        grid.addWidget(t, row, column)
      end
    end

    grid.setRowStretch(1, 1)
    grid.setColumnStretch(1, 1)
    grid.setColumnStretch(2, 1)

    return result
  end

  def wBorderLayout
    result = Wt::WContainerWidget.new
    topic("WBorderLayout", result)

    Wt::WText.new(tr("layout-WBorderLayout"), result)

    container = Wt::WContainerWidget.new(result)
    container.resize(Wt::WLength.new, Wt::WLength.new(400))
    container.styleClass = "yellow-box"
    layout = Wt::WBorderLayout.new
    container.layout = layout

    item = Wt::WText.new(tr("borderlayout-item").sub('{1}', "North"))
    item.styleClass = "green-box"
    layout.addWidget(item, Wt::WBorderLayout::North)

    item = Wt::WText.new(tr("borderlayout-item").sub('{1}', "West"))
    item.styleClass = "green-box"
    layout.addWidget(item, Wt::WBorderLayout::West)

    item = Wt::WText.new(tr("borderlayout-item").sub('{1}', "East"))
    item.styleClass = "green-box"
    layout.addWidget(item, Wt::WBorderLayout::East)

    item = Wt::WText.new(tr("borderlayout-item").sub('{1}', "South"))
    item.styleClass = "green-box"
    layout.addWidget(item, Wt::WBorderLayout::South)

    item = Wt::WText.new(tr("borderlayout-item").sub('{1}', "Center"))
    item.styleClass = "green-box"
    layout.addWidget(item, Wt::WBorderLayout::Center)

    return result
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
