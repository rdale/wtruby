#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class BasicControls < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("basics-intro"), self)

    #
    # Wt::WResource
    #   Wt::WMemoryResource
    #   Wt::WFileResource
    # Wt::WScrollArea
    # Wt::WScrollBar
    #
  end

  def populateSubMenu(menu)
    menu.addItem("WText", wText)
    menu.addItem("WBreak", wBreak)
    menu.addItem("WAnchor", wAnchor)
    menu.addItem("WImage", wImage)
    menu.addItem("WTable", wTable)
    menu.addItem("WContainerWidget", wContainerWidget)
    menu.addItem("WMenu", wMenu)
    menu.addItem("WTree", wTree)
    menu.addItem("WTreeTable", wTreeTable)
    menu.addItem("WPanel", wPanel)
    menu.addItem("WTabWidget", wTabWidget)
    menu.addItem("WGroupBox", wGroupBox)
    menu.addItem("WStackedWidget", wStackedWidget)
  end

  def wText
    result = Wt::WContainerWidget.new
    topic("WText", result)
    Wt::WText.new(tr("basics-WText"), result)
    
    Wt::WText.new("<p>This WText unexpectedly contains JavaScript, wich the " \
              "XSS attack preventer detects and disables. " \
              "<script>alert(\"You are under attack\");</script>" \
              "A warning is printed in Wt's log messages.</p>",
              result)
      
    Wt::WText.new("<p>This WText contains malformed XML <h1></h2>." \
              "It will be turned into a PlainText formatted string.</p>",
              result)

    Wt::WText.new(tr("basics-WText-events"), result)

    text = Wt::WText.new("This WText reacts on clicked<br/>", result)
    text.styleClass = "reactive"
    @ed.mapConnect(text.clicked, "WText clicked")

    text = Wt::WText.new("This WText reacts on doubleClicked<br/>", result)
    text.styleClass = "reactive"
    @ed.mapConnect(text.doubleClicked, "WText doubleClicked")

    text = Wt::WText.new("This WText reacts on mouseWentOver<br/>", result)
    text.styleClass = "reactive"
    @ed.mapConnect(text.mouseWentOver, "WText mouseWentOver")

    text = Wt::WText.new("This WText reacts on mouseWentOut<br/>", result)
    text.styleClass = "reactive"
    @ed.mapConnect(text.mouseWentOut, "WText mouseWentOut")

    return result
  end

  def wBreak
    result = Wt::WContainerWidget.new

    topic("WBreak", result)

    Wt::WText.new(tr("basics-WBreak"), result)

    Wt::WBreak.new(result) # does not really do anything useful :-)

    return result
  end

  def wAnchor
    result = Wt::WContainerWidget.new

    topic("WAnchor", result)

    Wt::WText.new(tr("basics-WAnchor"), result)

    a1 = Wt::WAnchor.new("http:#www.webtoolkit.eu/",
                              "Wt homepage (in a window.new)", result)
    a1.target = Wt::TargetNewWindow

    Wt::WText.new(tr("basics-WAnchor-more"), result)

    a2 = Wt::WAnchor.new("http:#www.webtoolkit.eu/", result)
    a2.target = Wt::TargetNewWindow
    Wt::WImage.new("icons/wt_powered.jpg", a2)

    Wt::WText.new(tr("basics-WAnchor-related"), result)
      
    return result
  end

  def wImage
    result = Wt::WContainerWidget.new

    topic("WImage", result)

    Wt::WText.new(tr("basics-WImage"), result)

    Wt::WText.new("An image: ", result)
    Wt::WImage.new("icons/wt_powered.jpg", result)

    Wt::WText.new(tr("basics-WImage-more"), result)

    return result
  end

  def wTable
    result = Wt::WContainerWidget.new

    topic("WTable", result)
    
    Wt::WText.new(tr("basics-WTable"), result)

    table = Wt::WTable.new(result)
    table.styleClass = "example-table"

    Wt::WText.new("First warning signal", table.elementAt(0, 0))
    Wt::WText.new("09:25am", table.elementAt(0, 1))
    img = Wt::WImage.new("icons/Pennant_One.png", table.elementAt(0, 2))
    img.resize(Wt::WLength.new, Wt::WLength.new(30, Wt::WLength::Pixel))
    Wt::WText.new("First perparatory signal", table.elementAt(1, 0))
    Wt::WText.new("09:26am", table.elementAt(1, 1))
    img = Wt::WImage.new("icons/Pennant_One.png", table.elementAt(1, 2))
    img.resize(Wt::WLength.new, Wt::WLength.new(30, Wt::WLength::Pixel))
    img = Wt::WImage.new("icons/Papa.png", table.elementAt(1, 2))
    img.resize(Wt::WLength.new, Wt::WLength.new(30, Wt::WLength::Pixel))
    Wt::WText.new("Second perparatory signal", table.elementAt(2, 0))
    Wt::WText.new("09:29am", table.elementAt(2, 1))
    img = Wt::WImage.new("icons/Pennant_One.png", table.elementAt(2, 2))
    img.resize(Wt::WLength.new, Wt::WLength.new(30, Wt::WLength::Pixel))
    Wt::WText.new("Start", table.elementAt(3, 0))
    Wt::WText.new("09:30am", table.elementAt(3, 1))

    Wt::WText.new(tr("basics-WTable-more"), result)

    return result
  end


  def wTree
    result = Wt::WContainerWidget.new

    topic("WTree", "WTreeNode", result)

    Wt::WText.new(tr("basics-WTree"), result)

    folderIcon = Wt::WIconPair.new("icons/yellow-folder-closed.png",
                                          "icons/yellow-folder-open.png", false)

    tree = Wt::WTree.new(result)
    tree.selectionMode = Wt::SingleSelection

    node = Wt::WTreeNode.new("Tree root", folderIcon)
    node.styleClass = "example-tree"
    tree.treeRoot = node
    # node.label.formatting = Wt::WText::PlainFormatting
    node.label.formatting = Wt::PlainFormatting
    node.imagePack = "resources/"
    node.loadPolicy = Wt::WTreeNode::NextLevelLoading
    node.addChildNode(Wt::WTreeNode.new("one"))
    node.addChildNode(Wt::WTreeNode.new("two"))

    three = Wt::WTreeNode.new("three")
    node.addChildNode(three)
    node.addChildNode(Wt::WTreeNode.new("four"))
    node.expand
    three.addChildNode(Wt::WTreeNode.new("Doc"))
    three.addChildNode(Wt::WTreeNode.new("Grumpy"))
    three.addChildNode(Wt::WTreeNode.new("Happy"))
    three.addChildNode(Wt::WTreeNode.new("Sneezy"))
    three.addChildNode(Wt::WTreeNode.new("Dopey"))
    three.addChildNode(Wt::WTreeNode.new("Bashful"))
    three.addChildNode(Wt::WTreeNode.new("Sleepy"))

    Wt::WText.new(tr("basics-WTree-more"), result)

    return result
  end

  def wTreeTable
    result = Wt::WContainerWidget.new

    topic("Wt::WTreeTable","WTreeTableNode", result)
    Wt::WText.new(tr("basics-WTreeTable"), result)
    tt = Wt::WTreeTable.new(result)
    tt.resize(Wt::WLength.new(650), Wt::WLength.new(300))
    tt.styleClass = "tree-table"
    tt.addColumn("Yuppie Factor", Wt::WLength.new(125))
    tt.addColumn("# Holidays", Wt::WLength.new(125))
    tt.addColumn("Favorite Item", Wt::WLength.new(125))
    ttr = Wt::WTreeTableNode.new("All Personnel")
    ttr.imagePack = "resources/"
    tt.setTreeRoot(ttr, "Emweb Organigram")
    ttr.styleClass = "treetablecol"
    ttr1 = Wt::WTreeTableNode.new("Upper Management", nil, ttr)
    ttn = Wt::WTreeTableNode.new("Chief Anything Officer", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("-2.8"))
    ttn.setColumnWidget(2, Wt::WText.new("20"))
    ttn.setColumnWidget(3, Wt::WText.new("Scepter"))
    ttn = Wt::WTreeTableNode.new("Vice President of Parties", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("13.57"))
    ttn.setColumnWidget(2, Wt::WText.new("365"))
    ttn.setColumnWidget(3, Wt::WText.new("Flag"))
    ttn = Wt::WTreeTableNode.new("Vice President of Staplery", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("3.42"))
    ttn.setColumnWidget(2, Wt::WText.new("27"))
    ttn.setColumnWidget(3, Wt::WText.new("Perforator"))
    ttr1 = Wt::WTreeTableNode.new("Middle management", nil, ttr)
    ttn = Wt::WTreeTableNode.new("Boss of the house", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("9.78"))
    ttn.setColumnWidget(2, Wt::WText.new("35"))
    ttn.setColumnWidget(3, Wt::WText.new("Happy Animals"))
    ttn = Wt::WTreeTableNode.new("Xena caretaker", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("8.66"))
    ttn.setColumnWidget(2, Wt::WText.new("10"))
    ttn.setColumnWidget(3, Wt::WText.new("Yellow bag"))
    ttr1 = Wt::WTreeTableNode.new("Actual Workforce", nil, ttr)
    ttn = Wt::WTreeTableNode.new("The Dork", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("9.78"))
    ttn.setColumnWidget(2, Wt::WText.new("22"))
    ttn.setColumnWidget(3, Wt::WText.new("Mojito"))
    ttn = Wt::WTreeTableNode.new("The Stud", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("8.66"))
    ttn.setColumnWidget(2, Wt::WText.new("46"))
    ttn.setColumnWidget(3, Wt::WText.new("Toothbrush"))
    ttn = Wt::WTreeTableNode.new("The Ugly", nil, ttr1)
    ttn.setColumnWidget(1, Wt::WText.new("13.0"))
    ttn.setColumnWidget(2, Wt::WText.new("25"))
    ttn.setColumnWidget(3, Wt::WText.new("Paper bag"))
    ttr.expand

    return result
  end

  def wPanel
    result = Wt::WContainerWidget.new

    topic("WPanel", result)

    Wt::WText.new(tr("basics-WPanel"), result)
    panel = Wt::WPanel.new(result)
    panel.centralWidget = Wt::WText.new("This is a default panel")
    Wt::WBreak.new(result)
    panel = Wt::WPanel.new(result)
    panel.title = "My second WPanel"
    panel.centralWidget = Wt::WText.new("This is a panel with a title")
    Wt::WBreak.new(result)
    panel = Wt::WPanel.new(result)
    panel.title = "My third WPanel"
    panel.setCentralWidget(Wt::WText.new("This is a collapsible panel with " \
                                      "a title"))
    panel.collapsible = true

    Wt::WText.new(tr("basics-WPanel-related"), result)

    return result
  end

  def wTabWidget
    result = Wt::WContainerWidget.new

    topic("WTabWidget", result)
    Wt::WText.new(tr("basics-WTabWidget"), result)
    tw = Wt::WTabWidget.new(result)
    tw.addTab(Wt::WText.new("These are the contents of the first tab"),
              "Picadilly", Wt::WTabWidget::PreLoading)
    tw.addTab(Wt::WText.new("The contents of these tabs are pre-loaded in " \
                        "the browser to ensure swift switching."),
              "Waterloo", Wt::WTabWidget::PreLoading)
    tw.addTab(Wt::WText.new("This is yet another pre-loaded tab. " \
                        "Look how good self works."),
              "Victoria", Wt::WTabWidget::PreLoading)
    tw.addTab(Wt::WText.new("The colors of the tab widget can be changed by " \
                        "modifying some images."),
              "Tottenham")

    tw.styleClass = "tabwidget"

    Wt::WText.new(tr("basics-WTabWidget-more"), result)

    return result
  end

  def wContainerWidget
    result = Wt::WContainerWidget.new

    topic("WContainerWidget", result)

    Wt::WText.new(tr("basics-WContainerWidget"), result)

    return result
  end

  def wMenu
    result = Wt::WContainerWidget.new

    topic("WMenu", result)
    Wt::WText.new(tr("basics-WMenu"), result)

    return result
  end

  def wGroupBox
    result = Wt::WContainerWidget.new

    topic("WGroupBox", result)
    Wt::WText.new(tr("basics-WGroupBox"), result)

    gb = Wt::WGroupBox.new("A group box", result)
    gb.addWidget(Wt::WText.new(tr("basics-WGroupBox-contents")))

    Wt::WText.new(tr("basics-WGroupBox-related"), result)

    return result
  end

  def wStackedWidget
    result = Wt::WContainerWidget.new

    topic("WStackedWidget", result)
    Wt::WText.new(tr("basics-WStackedWidget"), result)

    return result
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
