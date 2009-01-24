#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class ExtWidgets < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("ext-intro"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("Ext::Button",
                  deferCreate(:eButton, self))
    menu.addItem("Ext::LineEdit",
                  deferCreate(:eLineEdit, self))
    menu.addItem("Ext::NumberField",
                  deferCreate(:eNumberField, self))
    menu.addItem("Ext::CheckBox",
                  deferCreate(:eCheckBox, self))
    menu.addItem("Ext::ComboBox",
                  deferCreate(:eComboBox, self))
    menu.addItem("Ext::RadioButton",
                  deferCreate(:eRadioButton, self))
    menu.addItem("Ext::Calendar",
                  deferCreate(:eCalendar, self))
    menu.addItem("Ext::DateField",
                  deferCreate(:eDateField, self))
    menu.addItem("Ext::Menu/Wt::Ext::ToolBar",
                  deferCreate(:eMenu, self))
    menu.addItem("Ext::Dialog",
                  deferCreate(:eDialog, self))
    #menu.addItem("Wt::Ext::Splitter", Wt::WText.new("TODO: Wt::Ext::Splitter"))
  end

  def eButton
    result = Wt::WContainerWidget.new

    topic("Ext::Button", result)
    Wt::WText.new(tr("ext-Button"), result)

    ex = Wt::WContainerWidget.new(result)
    vLayout = Wt::WVBoxLayout.new
    ex.setLayout(vLayout, Wt::AlignTop)
    vLayout.setContentsMargins(0, 0, 0, 0)
    vLayout.spacing = 3

    vLayout.addWidget(button = Wt::Ext::Button.new("Push me!"))
    @ed.mapConnect(button.clicked, "Ext::Button clicked")
    vLayout.addWidget(button = Wt::Ext::Button.new("Checkable button"))
    button.checkable = true
    @ed.mapConnect(button.clicked, "Ext::Button (checkable) clicked")
    vLayout.addWidget(button = Wt::Ext::Button.new("Ext::Button with icon"))
    button.icon = "icons/yellow-folder-open.png"
    @ed.mapConnect(button.clicked, "Ext::Button (with icon) clicked")

    return result
  end

  def eLineEdit
    result = Wt::WContainerWidget.new

    topic("Ext::LineEdit", result)

    Wt::WText.new(tr("ext-LineEdit"), result)
    le = Wt::Ext::LineEdit.new(result)
    le.textSize = 50
    @ed.mapConnect(le.keyWentUp, "Ext::LineEdit keyWentUp")

    return result
  end

  def eNumberField
    result = Wt::WContainerWidget.new

    topic("Ext::NumberField", result)

    Wt::WText.new(tr("ext-NumberField"), result)
    Wt::WText.new("Total amount to pay: ", result)
    nf = Wt::Ext::NumberField.new(result)
    nf.decimalPrecision = 2
    nf.inline = true
    @ed.mapConnect(nf.keyPressed, "Ext::NumberField keyPressed")

    return result
  end

  def eCheckBox
    result = Wt::WContainerWidget.new

    topic("Ext::CheckBox", result)
    
    Wt::WText.new(tr("ext-CheckBox"), result)
    cb = Wt::Ext::CheckBox.new("Check me!", result)
    @ed.mapConnect(cb.checked, "Ext::CheckBox checked")
    cb = Wt::Ext::CheckBox.new("Check me too!", result)
    cb.checked = true
    @ed.mapConnect(cb.checked, "Ext::CheckBox too checked")

    return result
  end

  def eComboBox
    result = Wt::WContainerWidget.new

    topic("Ext::ComboBox", result)

    Wt::WText.new(tr("ext-ComboBox"), result)
    cb = Wt::Ext::ComboBox.new(result)
    cb.addItem("Stella")
    cb.addItem("Duvel")
    cb.addItem("Sloeber")
    cb.addItem("Westmalle")
    cb.addItem("Kwak")
    cb.addItem("Hoegaarden")
    cb.addItem("Palm")
    cb.addItem("Westvleteren")
    cb.currentIndex = 1
    @ed.mapConnect(cb.activated, "Ext::ComboBox activated")

    return result
  end

  def eRadioButton
    result = Wt::WContainerWidget.new

    topic("Ext::RadioButton", result)

    Wt::WText.new(tr("ext-RadioButton"), result)
    bg = Wt::WButtonGroup.new(result)
    rb = Wt::Ext::RadioButton.new("Kitchen", result)
    bg.addButton(rb)
    @ed.mapConnect(rb.checked, "Ext::RadioButton Kitchen checked")
    rb = Wt::Ext::RadioButton.new("Dining room", result)
    bg.addButton(rb)
    @ed.mapConnect(rb.checked, "Ext::RadioButton Dining Room checked")
    rb = Wt::Ext::RadioButton.new("Garden", result)
    bg.addButton(rb)
    @ed.mapConnect(rb.checked, "Ext::RadioButton Garden checked")
    rb = Wt::Ext::RadioButton.new("Attic", result)
    bg.addButton(rb)
    @ed.mapConnect(rb.checked, "Ext::RadioButton Attic checked")

    return result
  end

  def eCalendar
    result = Wt::WContainerWidget.new

    topic("Ext::Calendar", result)

    Wt::WText.new(tr("ext-Calendar"), result)
    c = Wt::Ext::Calendar.new(false, result)
    @ed.mapConnect(c.selectionChanged, "Ext::Calendar selectionChanged")

    return result
  end

  def eDateField
    result = Wt::WContainerWidget.new

    topic("Ext::DateField", result)

    Wt::WText.new(tr("ext-DateField"), result)
    df = Wt::Ext::DateField.new(result)
    df.format = "ddd MMM d yyyy"
    df.textSize = 25

    return result
  end

  def eMenu
    result = Wt::WContainerWidget.new

    topic("Ext::Menu", "Ext::ToolBar", result)

    Wt::WText.new(tr("ext-Menu"), result)
    menu = Wt::Ext::Menu.new

    item = menu.addItem("File open...")
    item.icon = "icons/yellow-folder-open.png"

    item = menu.addItem("I dig Wt")
    item.checkable = true
    item.checked = true
    
    item = menu.addItem("I dig Wt too")
    item.checkable = true

    menu.addSeparator
    menu.addItem("Ext::Menu item")
    menu.addSeparator

    # Add a sub menu

    subMenu = Wt::Ext::Menu.new
    subMenu.addItem("Do self")
    subMenu.addItem("And that")
    
    item = menu.addMenu("More ...", subMenu)
    item.icon = "icons/yellow-folder-open.png"
    
    # Create a tool bar
    
    toolBar = Wt::Ext::ToolBar.new(result)
    
    b = toolBar.addButton("Ext::Button w/Ext::Menu", menu)
    b.icon = "icons/yellow-folder-closed.png"
    
    toolBar.addButton("Ext::Button")
  
    toolBar.addSeparator
    toolBar.addButton("Separated")
    toolBar.addSeparator
    button = toolBar.addButton("Toggle me")
    button.checkable = true
    
    cb = Wt::Ext::ComboBox.new
    cb.addItem("Winter")
    cb.addItem("Spring")
    cb.addItem("Summer")
    cb.addItem("Autumn")
    toolBar.add(cb)

    return result
  end

  def eDialog
    result = Wt::WContainerWidget.new

    topic("Ext::Dialog", "Ext::MessageBox", "Ext::ProgressDialog", result)

    Wt::WText.new(tr("ext-Dialog"), result)

    return result
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
