#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'folderview.rb'
require 'csvutil.rb'

#! \class FileModel
#  \brief A specialized standard item model which report a specific
#         drag and drop mime type.
#
# A specific drag and drop mime type instead of the generic abstract
# item model is returned by the model.
#
class FileModel < Wt::WStandardItemModel
  DATE_DISPLAY_FORMAT = "MMM dd, yyyy"
  DATE_EDIT_FORMAT = "dd-MM-yyyy"

  def initialize(parent)
    super(parent)
  end

  def mimeType
    return FolderView::FILE_SELECTION_MIME_TYPE
  end
end

class FileView < Wt::WTreeView
  MAX_INT = 0x7ffffff

  def initilize(parent = nil)
    super(parent)
    doubleClicked.connect(SLOT(self, :edit))
  end

  # Edit a particular row.
  #
  def edit(item)
    modelRow = item.row

    d = Wt::WDialog.new("Edit...")
    d.resize(Wt::WLength.new(300), Wt::WLength.new)

    #
    # Create the form widgets, and load them with data from the model.
    #

    # name
    nameEdit = Wt::WLineEdit.new(model.data(modelRow, 1).value)

    # type
    typeEdit = Wt::WComboBox.new
    typeEdit.addItem("Document")
    typeEdit.addItem("Spreadsheet")
    typeEdit.addItem("Presentation")
    typeEdit.setCurrentIndex(typeEdit.findText(model.data(modelRow, 2).value))

    # size
    sizeEdit = Wt::WLineEdit.new(model.data(modelRow, 3).value)
    sizeEdit.validator = Wt::WIntValidator.new(0, MAX_INT, self)

    # created
    createdEdit = Wt::WLineEdit.new
    createdEdit.validator = Wt::WDateValidator.new(FileModel::DATE_EDIT_FORMAT, self)
    createdEdit.validator.mandatory = true

    createdPicker = Wt::WDatePicker.new(Wt::WImage.new("icons/calendar_edit.png"), createdEdit)
    createdPicker.format = FileModel::dateEditFormat
    createdPicker.setDate(model.data(modelRow, 4).value)

    # modified
    modifiedEdit = Wt::WLineEdit.new
    modifiedEdit.validator = Wt::WDateValidator.new(FileModel::DATE_EDIT_FORMAT, self)
    modifiedEdit.validator.mandatory = true

    modifiedPicker = Wt::WDatePicker.new(new Wt::WImage.new("icons/calendar_edit.png"), modifiedEdit)
    modifiedPicker.format = FileModel::DATE_EDIT_FORMAT
    modifiedPicker.setDate(model.data(modelRow, 5).value)

    #
    # Use a grid layout for the labels and fields
    #
    layout = Wt::WGridLayout.new

    row = 0
    l = nil

    layout.addWidget(l = Wt::WLabel.new("Name:"), row, 0)
    layout.addWidget(nameEdit, row, 1)
    l.buddy = nameEdit
    row += 1

    layout.addWidget(l = Wt::WLabel.new("Type:"), row, 0)
    layout.addWidget(typeEdit, row, 1, Wt::AlignTop)
    l.buddy = typeEdit
    row += 1

    layout.addWidget(l = Wt::WLabel.new("Size:"), row, 0)
    layout.addWidget(sizeEdit, row, 1)
    l.buddy = sizeEdit
    row += 1

    layout.addWidget(l = Wt::WLabel.new("Created:"), row, 0)
    layout.addWidget(createdEdit, row, 1)
    layout.addWidget(createdPicker, row, 2)
    l.buddy = createdEdit
    row += 1

    layout.addWidget(l = Wt::WLabel.new("Modified:"), row, 0)
    layout.addWidget(modifiedEdit, row, 1)
    layout.addWidget(modifiedPicker, row, 2)
    l.buddy = modifiedEdit
    row += 1

    buttons = Wt::WContainerWidget.new
    buttons.addWidget(b = Wt::WPushButton.new("Save"))
    b.clicked.connect(SLOT(d, :accept))
    d.contents.enterPressed.connect(SLOT(d, :accept))
    buttons.addWidget(b = Wt::WPushButton.new("Cancel"))
    b.clicked.connect(SLOT(d, :reject))

    #
    # Focus the form widget that corresonds to the selected item.
    #
    case item.column
    when 2
      typeEdit.setFocus
    when 3
      sizeEdit.setFocus
    when 4
      createdEdit.setFocus
    when 5
      modifiedEdit.setFocus
    else
      nameEdit.setFocus
    end

    layout.addWidget(buttons, row, 0, 0, 2, Wt::AlignCenter)
    layout.setColumnStretch(1, 1)

    d.contents.setLayout(layout, Wt::AlignTop | Wt::AlignJustify)

    if d.exec == Wt::WDialog::Accepted
      #
      # Update the model with data from the edit widgets.
      #
      # You will want to do some validation here...
      #
      # Note that we directly update the source model to avoid
      # problems caused by the dynamic sorting of the proxy model,
      # which reorders row numbers, and would cause us to switch to editing
      # the wrong data.
      #
      m = model

      proxyModel = m
      if proxyModel
        m = proxyModel.sourceModel
        modelRow = proxyModel.mapToSource(item).row
      end

      m.setData(modelRow, 1, Boost::Any.new(nameEdit.text))
      m.setData(modelRow, 2, Boost::Any.new(typeEdit.currentText))
      m.setData(modelRow, 3, Boost::Any.new(sizeEdit.text.to_i))
      m.setData(modelRow, 4, Boost::Any.new(createdPicker.date))
      m.setData(modelRow, 5, Boost::Any.new(modifiedPicker.date))
    end
  end
end

#! \class TreeViewDragDrop
#  \brief Main application class.
#
class TreeViewDragDrop < Wt::WApplication
  # The multi-threaded version of the wthttp lib doesn't work with Ruby
  MULTI_THREADED = false

  def initialize(env)
    super(env)
    @folderNameMap = {}
    messageResourceBundle.use("about")

    #
    # Create the data models.
    #
    @folderModel = Wt::WStandardItemModel.new(0, 1, self)
    populateFolders

    @fileModel = FileModel.new(self)
    populateFiles

    @fileFilterModel = Wt::WSortFilterProxyModel.new(self)
    @fileFilterModel.sourceModel = @fileModel
    @fileFilterModel.dynamicSortFilter = true
    @fileFilterModel.filterKeyColumn = 0
    @fileFilterModel.filterRole = Wt::UserRole

    #
    # Setup the user interface.
    #
    createUI

    #
    # Select the first folder
    #
    @folderView.select(@folderModel.index(0, 0, @folderModel.index(0, 0)))
  end

  # Setup the user interface.
  #
  def createUI
    w = root
    w.styleClass = "maindiv"

    #
    # The main layout is a 3x2 grid layout.
    #
    layout = Wt::WGridLayout.new
    layout.addWidget(createTitle("Folders"), 0, 0)
    layout.addWidget(createTitle("Files"), 0, 1)
    layout.addWidget(folderView, 1, 0)
    layout.addWidget(fileView, 1, 1)

    layout.addWidget(aboutDisplay, 2, 0, 1, 2, Wt::AlignTop)

    #
    # Let row 1 and column 1 take the excess space.
    #
    layout.setRowStretch(1, 1)
    layout.setColumnStretch(1, 1)

    w.layout = layout
  end

  # Creates a title widget.
  #
  def createTitle(title)
    result = Wt::WText.new(title)
    result.inline = false
    result.styleClass = "title"

    return result
  end

  # Creates the folder WTreeView
  #
  def folderView
    treeView = FolderView.new

    #
    # To support right-click, we need to disable the built-in browser
    # context menu.
    #
    # Note that disabling the context menu and catching the
    # right-click does not work reliably on all browsers.
    #
    treeView.setAttributeValue("oncontextmenu", "event.cancelBubble = true; event.returnValue = false; return false;")
    treeView.model = @folderModel
    treeView.resize(Wt::WLength.new(200), Wt::WLength.new)
    treeView.selectionMode = Wt::SingleSelection
    treeView.expandToDepth(1)
    treeView.selectionChanged.connect(SLOT(self, :folderChanged))

    treeView.mouseWentDown.connect(SLOT(self, :showPopup))

    @folderView = treeView

    return treeView
  end

  # Creates the file table view (also a WTreeView)
  #
  def fileView
    treeView = FileView.new

    # Hide the tree-like decoration on the first column, to make it
    # resemble a plain table
    treeView.rootIsDecorated = false

    treeView.model = @fileFilterModel
    treeView.selectionMode = Wt::ExtendedSelection
    treeView.dragEnabled = true

    treeView.setColumnWidth(0, Wt::WLength.new(100))
    treeView.setColumnWidth(1, Wt::WLength.new(150))
    treeView.setColumnWidth(2, Wt::WLength.new(100))
    treeView.setColumnWidth(3, Wt::WLength.new(80))
    treeView.setColumnWidth(4, Wt::WLength.new(120))
    treeView.setColumnWidth(5, Wt::WLength.new(120))

    treeView.setColumnFormat(4, FileModel::DATE_DISPLAY_FORMAT)
    treeView.setColumnFormat(5, FileModel::DATE_DISPLAY_FORMAT)

    treeView.setColumnAlignment(3, Wt::AlignRight)
    treeView.setColumnAlignment(4, Wt::AlignRight)
    treeView.setColumnAlignment(5, Wt::AlignRight)

    treeView.sortByColumn(1, Wt::AscendingOrder)

    @fileView = treeView

    return treeView
  end

  # Creates the hints text.
  #
  def aboutDisplay
    result = Wt::WText.new(tr("about-text"))
    result.styleClass = "about"
    return result
  end

  # Change the filter on the file view when the selected folder
  #         changes.
  #
  def folderChanged
    if @folderView.selectedIndexes.empty?
      return
    end

    selected = @folderView.selectedIndexes[0]
    d = selected.data(Wt::UserRole)
    if !d.empty
      folder = d.value

      # For simplicity, we assume here that the folder-id does not
      # contain special regexp characters, otherwise these need to be
      # escaped -- or use the \Q \E qutoing escape regular expression
      # syntax (and escape \E)
      @fileFilterModel.filterRegExp = folder
    end
  end

  # Show a popup for a folder item.
  #
  def showPopup(item, event)
    if MULTI_THREADED && event.button == Wt::WMouseEvent::RightButton

      # Select the item, it was not yet selected.
      @folderView.select(item)

      popup = Wt::WPopupMenu.new
      popup.addItem("icons/folder_new.gif", "Create a New Folder")
      popup.addItem("Rename this Folder").checkable = true
      popup.addItem("Delete this Folder")
      popup.addSeparator
      popup.addItem("Folder Details")
      popup.addSeparator
      popup.addItem("Application Inventory")
      popup.addItem("Hardware Inventory")
      popup.addSeparator

      subMenu = Wt::WPopupMenu.new
      subMenu.addItem("Sub Item 1")
      subMenu.addItem("Sub Item 2")
      popup.addMenu("File Deployments", subMenu)

      #
      # This is one method of executing a popup, i.e. by using a reentrant
      # event loop (blocking the current thread).
      #
      # Alternatively you could call WPopupMenu::popup, listen for
      # to the WPopupMenu::aboutToHide signal, and check the
      # WPopupMenu::result
      #
      item = popup.exec(event)

      if item
        #
        # You may bind extra data to an item using setData and
        # check here for the action asked.
        #
        Wt::WMessageBox::show("Sorry.",
                          "Action '" + item.text + "' is not implemented.",
                          Wt::Ok)
      end
    end
  end

  # Populate the files model.
  #
  # Data (and headers) is read from the CSV file data/files.csv. We
  # add icons to the first column, resolve the folder id to the
  # actual folder name, and configure item flags, and parse date
  # values.
  #
  def populateFiles 
    @fileModel.invisibleRootItem.rowCount = 0

    f = File.open("data/files.csv", "r")
    readFromCsv(f, @fileModel)

    for i in 0...@fileModel.rowCount
      item = @fileModel.item(i, 0)
      item.flags = item.flags | Wt::ItemIsDragEnabled.to_i
      item.icon = "icons/file.gif"

      folderId = item.text

      item.setData(Boost::Any.new(folderId), Wt::UserRole)
      item.text = @folderNameMap[folderId]

      convertToDate(@fileModel.item(i, 4))
      convertToDate(@fileModel.item(i, 5))
    end
  end

  # Convert a string to a date.
  #
  def convertToDate(item)
    d = Wt::WDate.fromString(item.text, FileModel::DATE_EDIT_FORMAT)
    item.setData(Boost::Any.new(d), Wt::DisplayRole)
  end

  # Populate the folders model.
  #
  def populateFolders
    level1 = nil
    level2 = nil
    @folderModel.appendRow(level1 = createFolderItem("San Fransisco"))
    level1.appendRow(level2 = createFolderItem("Investors", "sf-investors"))
    level1.appendRow(level2 = createFolderItem("Fellows", "sf-fellows"))

    @folderModel.appendRow(level1 = createFolderItem("Sophia Antipolis"))
    level1.appendRow(level2 = createFolderItem("R&D", "sa-r_d"))
    level1.appendRow(level2 = createFolderItem("Services", "sa-services"))
    level1.appendRow(level2 = createFolderItem("Support", "sa-support"))
    level1.appendRow(level2 = createFolderItem("Billing", "sa-billing"))

    @folderModel.appendRow(level1 = createFolderItem("New York"))
    level1.appendRow(level2 = createFolderItem("Marketing", "ny-marketing"))
    level1.appendRow(level2 = createFolderItem("Sales", "ny-sales"))
    level1.appendRow(level2 = createFolderItem("Advisors", "ny-advisors"))

    @folderModel.appendRow(level1 = createFolderItem("Frankfürt"))
    level1.appendRow(level2 = createFolderItem("Sales", "frank-sales"))

    @folderModel.setHeaderData(0, Wt::Horizontal, Boost::Any.new("SandBox"))
  end

  # Create a folder item.
  #
  # Configures flags for drag and drop support.
  #
  def createFolderItem(location, folderId = "")
    result = Wt::WStandardItem.new(location)

    if !folderId.empty?
      result.data = Boost::Any.new(folderId)
      result.flags = result.flags | Wt::ItemIsDropEnabled.to_i
      @folderNameMap[folderId] = location
    else
      result.flags = result.flags & ~Wt::ItemIsSelectable.to_i
    end

    result.icon = "icons/folder.gif"
    return result
  end
end

Wt::WRun(ARGV) do |env|
  app = TreeViewDragDrop.new(env)
  app.title = "WTreeView Drag & Drop"
  app.useStyleSheet("styles.css")
  # This works if it is called in the WApplication constructor,
  # but not here
  # app.messageResourceBundle.use("about")
  app.refresh
  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
