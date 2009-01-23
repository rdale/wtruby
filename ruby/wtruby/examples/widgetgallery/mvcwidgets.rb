#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class MvcWidgets < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("mvc-intro"), self)

    @stringList = Wt::WStringListModel.new(self)
    strings = []
    strings.push("Alfa")
    strings.push("Bravo")
    strings.push("Charly")
    strings.push("Delta")
    strings.push("Echo")
    strings.push("Foxtrot")
    strings.push("Golf")
    strings.push("Hotel")
    strings.push("Indiana Jones")
    @stringList.stringList = strings

  end

  def populateSubMenu(menu)
    menu.addItem("The Models", models)
    menu.addItem("Combobox Views",
                  deferCreate(:viewsCombo, self))
    menu.addItem("WTreeView", viewsTree)
    menu.addItem("Chart Views", viewsChart)
    menu.addItem("Ext::TableView",
                  deferCreate(:viewsExtTable, self))
  end

  def comboBoxAdd
    if @extComboBox.currentIndex == -1
      sl = @stringList.stringList
      sl.push(@extComboBox.currentText)
      #std::cout << "combobox text: " << @extComboBox.currentText << std::endl
      #sl.push("Blabla")
      @stringList.stringList = sl
      #@stringList.insertRows(0, 1)
      #@stringList.setData(0, 0, "Blabla")
    end
  end

  def models
    result = Wt::WContainerWidget.new

    topic("WAbstractItemModel", "WAbstractListModel", "WStandardItemModel",
          "WStringListModel", result)
    Wt::WText.new(tr("mvc-models"), result)
    return result
  end

  def viewsCombo
    result = Wt::WContainerWidget.new

    # Wt::WComboBox
    topic("WComboBox", "WSelectionBox", "Ext::ComboBox", result)
    Wt::WText.new(tr("mvc-stringlistviews"), result)
    Wt::WText.new("<h3>WComboBox</h3>", result)
    (Wt::WComboBox.new(result)).model = @stringList

    # Wt::WSelectionBox
    Wt::WText.new("<h3>WSelectionBox</h3>", result)
    (Wt::WSelectionBox.new(result)).model = @stringList

    # Wt::Ext::ComboBox
    Wt::WText.new("<h3>Ext::ComboBox</h3>", result)
    @extComboBox = Wt::Ext::ComboBox.new(result)
    @extComboBox.model = @stringList
    @extComboBox.editable = true
    pb = Wt::WPushButton.new("Press here to add the edited value " \
                                      "to the model", result)
    pb.clicked.connect(SLOT(self, :comboBoxAdd))
    
    return result
  end

  def viewsExtTable
    result = Wt::WContainerWidget.new

    topic("Ext::TableView", result)
    Wt::WText.new(tr("mvc-ExtTable"), result)
    return result
  end

  def viewsTree
    result = Wt::WContainerWidget.new

    topic("WTreeView", result)
    Wt::WText.new(tr("mvc-WTreeView"), result)
    # TreeViewExample.new(false, result)
    return result
  end

  def viewsChart
    result = Wt::WContainerWidget.new

    topic("Chart::WCartesianChart", "Chart::WPieChart", result)
    Wt::WText.new(tr("mvc-Chart"), result)
    return result
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
