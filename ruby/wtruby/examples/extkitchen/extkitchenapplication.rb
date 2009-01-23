#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

require 'wt'
require 'wtext'
require 'csvutil.rb'

class ExtKitchenApplication < Wt::WApplication

  def initialize(env)
    super(env)
    setTitle("Wt-Ext, including a kitchen sink")
  
    useStyleSheet("extkitchen.css")
    messageResourceBundle.use("extkitchen")
  
    viewPort = Wt::Ext::Container.new(root)
    layout = Wt::WBorderLayout.new(viewPort)
  
    # North
    north = Wt::Ext::Panel.new
    north.border = false
    head = Wt::WText.new(tr("header"))
    head.styleClass = "north"
    north.layout = Wt::WFitLayout.new
    north.layout.addWidget(head)
    north.resize(Wt::WLength.new, Wt::WLength.new(35))
    layout.addWidget(north, Wt::WBorderLayout::North)

    # West
    west = Wt::Ext::Panel.new
    west.layout.addWidget(createExampleTree)
  
    west.title = "Widgets"
    west.resize(Wt::WLength.new(200), Wt::WLength.new)
    west.resizable = true
    west.collapsible = true
    west.animate = true
    west.autoScrollBars = true
    layout.addWidget(west, Wt::WBorderLayout::West)

    # Center
    center = Wt::Ext::Panel.new
    center.title = "Demo widget"
    @exampleContainer = Wt::WContainerWidget.new
    center.layout.addWidget(@exampleContainer)
    center.autoScrollBars = true
    layout.addWidget(center, Wt::WBorderLayout::Center)
  
    @exampleContainer.padding = Wt::WLength.new(5)
  
    container = Wt::WContainerWidget.new(@exampleContainer)
    container.addWidget(Wt::WText.new(tr("about")))
    @currentExample = container
  
    # load an Ext them, after at least one Ext widget. For example, here:
    #useStyleSheet("ext/resources/css/xtheme-gray.css")
  end

  def createExampleTree
    mapIcon = Wt::WIconPair.new(  "icons/yellow-folder-closed.png",
                                  "icons/yellow-folder-open.png", false )
  
    rootNode = Wt::WTreeNode.new("Examples", mapIcon)
    rootNode.imagePack = "icons/"
    rootNode.expand
    rootNode.loadPolicy = Wt::WTreeNode::NextLevelLoading
  
    createExampleNode("Menu & ToolBar", rootNode, :menuAndToolBarExample)
    createExampleNode("Form widgets", rootNode, :formWidgetsExample)
    createExampleNode("TableView", rootNode, :tableViewExample)
    createExampleNode("Dialogs", rootNode, :dialogExample)
    createExampleNode("TabWidget", rootNode, :tabWidgetExample)
  
    rootNode.margin = Wt::WLength.new(5)
  
    return rootNode
  end

  def createExampleNode(label, parentNode, f)
    labelIcon = Wt::WIconPair.new("icons/document.png", "icons/document.png", false)
  
    node = Wt::WTreeNode.new(label, labelIcon, parentNode)
    node.label.formatting = Wt::PlainFormatting
    node.label.clicked.connect(SLOT(self, f))
  
    return node
  end

  def setExample(example)
    if @currentExample
#      @currentExample.dispose
      @exampleContainer.removeWidget(@currentExample)
      @currentExample.hide
    end

    @currentExample = example
    @exampleContainer.addWidget(@currentExample)
  end

  def menuAndToolBarExample
    ex = Wt::WContainerWidget.new
  
    wt = Wt::WText.new(false, tr("ex-menu-and-toolbar"), ex)
    wt.margin = Wt::WLength.new(5, Wt::WWidget::Bottom)
  
    # Create a menu with some items
  
    menu = Wt::Ext::Menu.new
  
    item = menu.addItem("File open...")
    item.icon = "icons/yellow-folder-open.png"
  
    item = menu.addItem("I dig Wt")
    item.checkable = true
    item.checked = true
  
    item = menu.addItem("I dig Wt too")
    item.checkable = true
  
    menu.addSeparator
    menu.addItem("Menu item")
    menu.addSeparator
  
    # Add a sub menu
  
    subMenu = Wt::Ext::Menu.new
    subMenu.addItem("Do self")
    subMenu.addItem("And that")
  
    item = menu.addMenu("More ...", subMenu)
    item.icon = "icons/yellow-folder-open.png"
  
    # Create a tool bar
  
    toolBar = Wt::Ext::ToolBar.new(ex)
  
    b = toolBar.addButton("Button w/Menu", menu)
    b.icon = "icons/yellow-folder-closed.png"
  
    toolBar.addButton("Button")
  
    toolBar.addSeparator
    toolBar.addButton("Separated")
    toolBar.addSeparator
    button = toolBar.addButton("Toggle me")
    button.checkable = true
  
    @cb = Wt::Ext::ComboBox.new
    @cb.addItem("Winter")
    @cb.addItem("Spring")
    @cb.addItem("Summer")
    @cb.addItem("Autumn")
    toolBar.add(@cb)
  
    setExample(ex)
  end

  def formWidgetsExample
    ex = Wt::WContainerWidget.new
  
    wt = Wt::WText.new(false, tr("ex-form-widgets"), ex)
    wt.setMargin(Wt::WLength.new(5), Wt::WWidget::Bottom)
  
    table = Wt::WTable.new(ex)
  
    # ComboBox
    @cb = Wt::Ext::ComboBox.new(table.elementAt(0, 0))
    @cb.addItem("One")
    @cb.addItem("Two")
    @cb.addItem("Three")

    #
    # This is how you would keep the data on the server (for really big
    # data models:

=begin
    @cb.dataLocation = Wt::Ext::ServerSide
    @cb.minQueryLength = 0
    @cb.queryDelay = 0
    @cb.pageSize = 10
    @cb.textSize = 20
=end

    # Button
    button = Wt::Ext::Button.new("Modify", table.elementAt(0, 1))
    button.setMargin(Wt::WLength.new(5), Wt::WWidget::Left)
    button.activated.connect(SLOT(self, :formModify))
  
    # CheckBox
    cb1 = Wt::Ext::CheckBox.new("Check 1", table.elementAt(1, 0))
    cb2 = Wt::Ext::CheckBox.new("Check 2", table.elementAt(2, 0))
    cb2.setChecked

    #-- test setHideWithOffsets of Wt::Ext::ComboBox
=begin
    table.hide
    b = Wt::WPushButton.new("show", ex)
    b.clicked.connect(SLOT(table, :show))
=end

    # DateField
    df = Wt::Ext::DateField.new(ex)
    df.setMargin(Wt::WLength.new(5), Wt::WWidget::Top | Wt::WWidget::Bottom)
    df.setDate(Wt::WDate.new(2007, 9, 7))
  
    # Calendar
    dp = Wt::Ext::Calendar.new(false, ex)
  
    # TextEdit
    @html = Wt::Ext::TextEdit.new("Hello there, <b>brothers and sisters</b>", ex)
    @html.setMargin(Wt::WLength.new(5), Wt::WWidget::Top | Wt::WWidget::Bottom)
    @html.resize(Wt::WLength.new(600), Wt::WLength.new(300))
  
    # Horizontal Splitter
    split = Wt::Ext::Splitter.new(ex)
    split.resize(Wt::WLength.new(400), Wt::WLength.new(100))
  
    split.addWidget(Wt::WText.new("Left"))
    split.children.last.resize(Wt::WLength.new(150), Wt::WLength.new)
    split.children.last.setMinimumSize(Wt::WLength.new(130), Wt::WLength.new)
    split.children.last.setMaximumSize(Wt::WLength.new(170), Wt::WLength.new)

    split.addWidget(Wt::WText.new("Center"))
    split.children.last.resize(Wt::WLength.new(100), Wt::WLength.new)
    split.children.last.setMinimumSize(Wt::WLength.new(50), Wt::WLength.new)
  
    split.addWidget(Wt::WText.new("Right"))
    split.children.last.resize(Wt::WLength.new(50), Wt::WLength.new)
    split.children.last.setMinimumSize(Wt::WLength.new(50), Wt::WLength.new)
  
    # Vertical Splitter
    split = Wt::Ext::Splitter.new(Wt::Vertical, ex)
    split.resize(Wt::WLength.new(100), Wt::WLength.new(200))
  
    split.addWidget(Wt::WText.new("Top"))
    split.children.last.resize(Wt::WLength.new, Wt::WLength.new(100))
    split.children.last.setMinimumSize(Wt::WLength.new, Wt::WLength.new(50))
    split.children.last.setMaximumSize(Wt::WLength.new, Wt::WLength.new(196))
  
    split.addWidget(Wt::WText.new("Center"))
    split.children.last.resize(Wt::WLength.new, Wt::WLength.new(100))
  
    setExample(ex)
  end

  def tableViewExample
    ex = Wt::WContainerWidget.new
  
    wt = Wt::WText.new(false, tr("ex-table-view"), ex)
    wt.setMargin(Wt::WLength.new(5), Wt::WWidget::Bottom)
  
    #
    # Create the data model, and load from a CSV file
    #
    @model = Wt::WStandardItemModel.new(0, 0, ex)
    f = File.open("compare.csv", "r")
    readFromCsv(f, @model)
  
    #
    # Convert the last column to Wt::WDate
    #
    for i in 0...@model.rowCount
      j = @model.columnCount - 1
      dStr = @model.data(i, j).value
      @model.setData(i, j, Boost::Any.new(Wt::WDate.fromString(dStr, "d/M/yyyy")))
    end

    #
    # Create a read-only Wt::Ext::TableView for the model
    #
    @table1 = Wt::Ext::TableView.new(ex)
    @table1.resize(Wt::WLength.new(700), Wt::WLength.new(250))
    @table1.model = @model
    @table1.setColumnSortable(0, true)
    @table1.enableColumnHiding(0, true)
    @table1.alternatingRowColors = true
    @table1.autoExpandColumn = 2
    @table1.setRenderer(@model.columnCount - 1, Wt::Ext::TableView.dateRenderer("d MMM yyyy"))

    #
    # Leave the data on the server, and add a paging tool
    #
    @table1.dataLocation = Wt::Ext::ServerSide
    @table1.pageSize = 10
    @table1.bottomToolBar = @table1.createPagingToolBar
    @table1.bottomToolBar.addButton("Other button")

    #
    # A second editable Wt::Ext::TableView for the same model inside a tab
    # widget.
    #
    wt = Wt::WText.new(false, tr("ex-table-view2"), ex)
    wt.setMargin(Wt::WLength.new(5), Wt::WWidget::Bottom)
  
    @tb = Wt::Ext::TabWidget.new(ex)
    @table2 = Wt::Ext::TableView.new
    @tb.addTab(@table2)
    @tb.addTab(Wt::WText.new(tr("tab-2-content")), "Tab 2")
  
    @tb.resize(Wt::WLength.new(600), Wt::WLength.new(250))
  
    @table2.title = "Editable TableView"
    @table2.model = @model
    @table2.resizeColumnsToContents(true)
    @table2.autoExpandColumn = 2
    @table2.setRenderer(@model.columnCount - 1, Wt::Ext::TableView.dateRenderer("dd/MM/yyyy"))

    # Set a Wt::Ext::LineEdit for the first field
    @table2.setEditor(0, Wt::Ext::LineEdit.new)
  
    # Set a Wt::Ext::ComboBox for the second field
    @cb = Wt::Ext::ComboBox.new
    @cb.addItem("Library")
    @cb.addItem("Servlet")
    @cb.addItem("Framework")
    @table2.setEditor(1, @cb)
  
    # Set a Wt::Ext::DateField for the last field
    df = Wt::Ext::DateField.new
    df.format = "dd/MM/yyyy"
    @table2.setEditor(@model.columnCount - 1, df)
  
    toolBar = Wt::Ext::ToolBar.new
    toolBar.addButton("Add 1000 rows", SLOT(self, :addRow))
    toolBar.addButton("Remove 1 row", SLOT(self, :removeRow))
    toolBar.addButton("Reset", SLOT(self, :resetModel))
    @table2.bottomToolBar = toolBar
  
    #
    # A Wt::WTreeTable in another tab widget -- they all don't mind eachother
    #
    @treeTable = Wt::WTreeTable.new
    @treeTable.tree.selectionMode = Wt::ExtendedSelection
    @treeTable.styleClass = "table"
    @treeTable.addColumn("Cost", Wt::WLength.new(200))
  
    root = Wt::WTreeTableNode.new("Root")
    @treeTable.setTreeRoot(root, "Child")
    root.imagePack = "icons/"
    root.childCountPolicy = Wt::WTreeNode::Enabled
    addChildren
  
    p = Wt::Ext::Panel.new
    p.layout = Wt::WFitLayout.new
    p.layout.addWidget(@treeTable)
    p.title = "Tab 3"
    toolBar = Wt::Ext::ToolBar.new
    toolBar.addButton("Add 20 rows", SLOT(self, :addChildren))
    p.topToolBar = toolBar
  
    @tb.addTab(p)
  
    setExample(ex)
  end

  def addChildren
    root = @treeTable.treeRoot
    while !root.childNodes.empty? do
      root = root.childNodes[0]
    end

    for i in 0...20
      c = root.childNodes.size + 1
      v = Wt::WTreeTableNode.new("Child " + c.to_s, nil)
      root.addChildNode(v)
      v.setColumnWidget(1, Wt::WText.new("$" + (c*20).to_s))
    end
  end

  def addRow
    # Add some new rows at the end of the model
    for i in 0...1000
      r = @model.rowCount
      @model.insertRow(r)
      @model.setData(r, 0, Boost::Any.new("Mine"))
      @model.setData(r, 1, Boost::Any.new("Framework"))
      @model.setData(r, 2, Boost::Any.new("JavaScript"))
      @model.setData(r, 3, Boost::Any.new("No"))
      @model.setData(r, 4, Boost::Any.new("No"))
      @model.setData(r, 5, Boost::Any.new(Wt::WDate.currentDate))
    end
  end

  def removeRow
    # Remove the first row
    @model.removeRow(0)
  end

  def resetModel
    # Reset the original model
    model = Wt::WStandardItemModel.new(0, 0, self)

    f = File.open("compare.csv", "r")
    readFromCsv(f, model)
  
    @table1.model = model
    @table2.model = model
  
    @model.dispose
    @model = model
  end

  def formModify
    $stderr.puts @cb.currentText + ", " + @cb.currentIndex.to_s
    @cb.addItem("Four?")
  end

  def dialogExample
    ex = Wt::WContainerWidget.new
  
    vLayout = Wt::WVBoxLayout.new
    ex.setLayout(vLayout, Wt::AlignTop | Wt::AlignLeft)
    vLayout.setContentsMargins(0, 0, 0, 0)
    vLayout.spacing = 3
  
    vLayout.addWidget(Wt::WText.new(false, tr("ex-dialogs")))

    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 1"))
    button.activated.connect(SLOT(self, :createDialog))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 2"))
    button.activated.connect(SLOT(self, :createDialog2))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 3"))
    button.activated.connect(SLOT(self, :createDialog3))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 4"))
    button.activated.connect(SLOT(self, :createDialog4))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 5"))
    button.activated.connect(SLOT(self, :createDialog5))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 6"))
    button.activated.connect(SLOT(self, :createDialog6))
    vLayout.addWidget(button = Wt::Ext::Button.new("Dialog 7"))
    button.activated.connect(SLOT(self, :createDialog7))
  
    setExample(ex)
  end

  def createDialog
    @mbox = Wt::Ext::MessageBox.new
    @mbox.resize(Wt::WLength.new(300), Wt::WLength.new(100))
    @mbox.windowTitle = "Hello there"
  
    @mbox.buttons = Wt::Ok
    @mbox.finished.connect(SLOT(self, :testDelete))
  
    @mbox.show
  end

  def testDelete
    @mbox.hide
  end

  def createDialog2
    d = Wt::Ext::Dialog.new
    d.windowTitle = "Hello there too"
    d.resize(Wt::WLength.new(300), Wt::WLength.new(100))
  
    okButton = Wt::Ext::Button.new("Ok")
    okButton.activated.connect(SLOT(d, :accept))
    d.addButton(okButton)
    okButton.default = true
  
    cancelButton = Wt::Ext::Button.new("Cancel")
    cancelButton.activated.connect(SLOT(d, :reject))
    d.addButton(cancelButton)
  
    contents = Wt::WText.new("I'm right here.")
    d.contents.addWidget(contents)
    d.exec
  
    d.windowTitle = "Good to see you."
    contents.text = "I've been waiting for you."
    d.exec
  end

  def createDialog3
    d = Wt::Ext::Dialog.new
    d.windowTitle = "Ext::Dialog with WBorderLayout"
    d.resize(Wt::WLength.new(400), Wt::WLength.new(300))
    d.styleClass = "dialog"
  
    okButton = Wt::Ext::Button.new("Ok")
    okButton.activated.connect(SLOT(d, :accept))
    d.addButton(okButton)
    okButton.default = true
  
    cancelButton = Wt::Ext::Button.new("Cancel")
    cancelButton.activated.connect(SLOT(d, :reject))
    d.addButton(cancelButton)
  
    layout = Wt::WBorderLayout.new
    d.layout = layout
  
    west = Wt::Ext::Panel.new
    west.title = "West"
    west.resizable = true
    west.resize(Wt::WLength.new(100), Wt::WLength.new)
    layout.addWidget(west, Wt::WBorderLayout::West)
  
    center = Wt::Ext::Panel.new
    center.title = "Center"
  
    nestedLayout = Wt::WBorderLayout.new
    center.layout = nestedLayout
  
    nestedNorth = Wt::Ext::Panel.new
    nestedLayout.addWidget(nestedNorth, Wt::WBorderLayout::North)
    nestedNorth.resize(Wt::WLength.new, Wt::WLength.new(35))
    nestedNorth.layout.addWidget(Wt::WText.new(tr("nested-header")))
  
    nestedCenter = Wt::Ext::Panel.new
    nestedLayout.addWidget(nestedCenter, Wt::WBorderLayout::Center)
    nestedCenter.layout.addWidget(Wt::WText.new(tr("dialog-nested")))
  
    layout.addWidget(center, Wt::WBorderLayout::Center)
  
    d.exec
  end

  def createDialog4
    if Wt::Ext::MessageBox.show("Confirm", "I am amazed", Wt::Ok | Wt::Cancel) == Wt::Ok
      $stderr.puts "Got ok."
    else
      $stderr.puts "Got cancel."
    end
  end

  def createDialog5
    v = "Jozef"
  
    if Wt::Ext::MessageBox.prompt("Info", "Please enter your name:", v) == Wt::Ok
      $stderr.puts "You entered: '" + v + "'"
    end
  end

  def createDialog6
    d = Wt::Ext::ProgressDialog.new("Converting contact details...", "Cancel", 0, 7)
    d.windowTitle = "Import Contacts"
  
    d.show
  
    for i in 0...7
      d.value = i
      processEvents
  
      if !d.wasCanceled
        # Do some work ...
        sleep(1)
      else
        Wt::Ext::MessageBox.show( "Operation cancelled",
                                  "You may import your contact details any time later.", 
                                  Wt::Ok )
        break
      end
    end
  end

  def createDialog7
    d = Wt::Ext::Dialog.new
    d.windowTitle = "Shhh..."
  
    d.resize(Wt::WLength.new(350), Wt::WLength.new(120))
  
    okButton = Wt::Ext::Button.new("Ok")
    okButton.activated.connect(SLOT(d, :accept))
    d.addButton(okButton)
    okButton.default = true
  
    cancelButton = Wt::Ext::Button.new("Cancel")
    cancelButton.activated.connect(SLOT(d, :reject))
    d.addButton(cancelButton)
  
    d.contents.padding = Wt::WLength.new(8)
    Wt::WText.new("Please give your password:", d.contents)
  
    passwd = Wt::Ext::LineEdit.new(d.contents)
    passwd.echoMode = Wt::Ext::LineEdit::Password
    passwd.textSize = 8
    passwd.margin = Wt::WLength.new(5, Wt::WWidget::Left)
    passwd.inline = true
  
    d.contents.enterPressed.connect(SLOT(d, :accept))
  
    if d.exec == Wt::Ext::Dialog::Accepted
      # ...
    end
  end

  def tabWidgetExample
    ex = Wt::WContainerWidget.new
  
    wt = Wt::WText.new(false, tr("ex-tabwidget"), ex)
    wt.margin = Wt::WLength.new(5, Wt::WWidget::Bottom)
  
    @tb = Wt::Ext::TabWidget.new(ex)
    @tb.resize(Wt::WLength.new(500), Wt::WLength.new(200))
    @tb.addTab(Wt::WText.new(tr("tab-1-content")), "Tab 1")
    @tb.addTab(Wt::WText.new(tr("tab-2-content")), "Tab 2")
  
    w = Wt::WContainerWidget.new(ex)
    hLayout = Wt::WHBoxLayout.new
    w.setLayout(hLayout, Wt::AlignTop | Wt::AlignLeft)
    hLayout.setContentsMargins(0, 9, 0, 0)
  
    b = Wt::Ext::Button.new("Hide")
    hLayout.addWidget(b)
    b.clicked.connect(SLOT(self, :hideTab))
  
    b = Wt::Ext::Button.new("Show")
    hLayout.addWidget(b)
    b.clicked.connect(SLOT(self, :showTab))
  
    b = Wt::Ext::Button.new("Add tab")
    hLayout.addWidget(b)
    b.clicked.connect(SLOT(self, :modifyTabWidget))
    b.toolTip = "Adds a tab"
  
    setExample(ex)
  end

  def modifyTabWidget
    @tb.addTab(Wt::WText.new(tr("tab-x-content")),
               "Tab " + (@tb.count+ 1).to_s)
  end

  def hideTab
    @tb.currentIndex = 1
    @tb.setTabHidden(0, true)
  end

  def showTab
    @tb.setTabHidden(0, false)
  end
end

Wt::WRun(ARGV) do |env|
  GC.disable
  ExtKitchenApplication.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
