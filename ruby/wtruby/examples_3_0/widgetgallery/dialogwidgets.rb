#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class DialogWidgets < ControlsWidget
  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("dialogs-intro"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("WDialog", wDialog)
    menu.addItem("WMessageBox", wMessageBox)
    menu.addItem("Ext Dialogs",
                  deferCreate(:eDialogs, self))
  end

  def wDialog
    result = Wt::WContainerWidget.new

    topic("WDialog", result)
    Wt::WText.new(tr("dialogs-WDialog"), result)
    button = Wt::WPushButton.new("Familiar", result)
    button.clicked.connect(SLOT(self, :custom))

    return result
  end

  def wMessageBox
    result = Wt::WContainerWidget.new

    topic("WMessageBox", result)
    Wt::WText.new(tr("dialogs-WMessageBox"),
              result)
    
    ex = Wt::WContainerWidget.new(result)
    
    vLayout = Wt::WVBoxLayout.new
    ex.setLayout(vLayout, Wt::AlignTop)
    vLayout.setContentsMargins(0, 0, 0, 0)
    vLayout.spacing = 3

    vLayout.addWidget(button = Wt::WPushButton.new("One liner"))
    button.clicked.connect(SLOT(self, :messageBox1))
    vLayout.addWidget(button = Wt::WPushButton.new("Show some buttons"))
    button.clicked.connect(SLOT(self, :messageBox2))
    vLayout.addWidget(button = Wt::WPushButton.new("Need confirmation"))
    button.clicked.connect(SLOT(self, :messageBox3))
    vLayout.addWidget(button = Wt::WPushButton.new("Discard"))
    button.clicked.connect(SLOT(self, :messageBox4))

    return result
  end

  def eDialogs
    result = Wt::WContainerWidget.new

    topic("Ext::Dialog", "Ext::MessageBox", "Ext::ProgressDialog", result)
    Wt::WText.new(tr("dialogs-ExtDialog"), result)
    ex = Wt::WContainerWidget.new(result)
    
    vLayout = Wt::WVBoxLayout.new
    ex.setLayout(vLayout, Wt::AlignTop)
    vLayout.setContentsMargins(0, 0, 0, 0)
    vLayout.spacing = 3
    
    vLayout.addWidget(button = Wt::WPushButton.new("Ext Message Box"))
    button.clicked.connect(SLOT(self, :createExtMessageBox))
    vLayout.addWidget(button = Wt::WPushButton.new("Ext Dialog"))
    button.clicked.connect(SLOT(self, :createExtDialog))
    vLayout.addWidget(button = Wt::WPushButton.new("Ext Progress Bar"))
    button.clicked.connect(SLOT(self, :createExtProgress))

    return result
  end

  def messageBox1
    Wt::WMessageBox::show("Information",
                      "One-liner dialogs have a simple constructor", Wt::Ok)
    @ed.status = "Ok'ed"
  end

  def messageBox2
    @messageBox = Wt::WMessageBox.new("Question",
                        "This is a modal dialog that invokes a signal when a button is pushed",
                        Wt::NoIcon, Wt::Yes | Wt::No | Wt::Cancel)

    @messageBox.buttonClicked.connect(SLOT(self, :messageBoxDone))

    @messageBox.show
  end

  def messageBox3
    result = Wt::WMessageBox::show("Push it",
                               "Yes/No questions can be tested by " \
                               "checking show's return value",
                               Wt::Ok | Wt::Cancel)

    if result == Wt::Ok
      @ed.status = "Accepted!"
    else
      @ed.status = "Cancelled!"
    end
  end

  def messageBox4
    @messageBox = Wt::WMessageBox.new("Your work",
                        "Provide your own button text.<br/>" \
                        "Your work is not saved",
                        Wt::NoIcon, Wt::NoButton)

    @messageBox.addButton("Cancel modifications", Wt::Cancel)
    @messageBox.addButton("Continue modifying work", Wt::Ok)

    @messageBox.buttonClicked.connect(SLOT(self, :messageBoxDone))

    @messageBox.show
  end

  def messageBoxDone(result)
    case result
    when Wt::Ok
      @ed.status = "Ok'ed"
    when Wt::Cancel
      @ed.status = "Cancelled!"
    when Wt::Yes
      @ed.status = "Me too!"
    when Wt::No
      @ed.status = "Me neither!"
    else
      @ed.status = "Unknown result?"
    end

    # delete @messageBox
    @messageBox = nil
  end

  def custom
    dialog = Wt::WDialog.new("Personalia")

    Wt::WText.new("You can freely format the contents of a WDialog by " \
              "adding any widget you want to it.<br/>Here, we added WText, " \
              "WLineEdit and WPushButton to a dialog", dialog.contents)
    Wt::WBreak.new(dialog.contents)
    Wt::WText.new("Enter your name: ", dialog.contents)
    edit = Wt::WLineEdit.new(dialog.contents)
    Wt::WBreak.new(dialog.contents)
    ok = Wt::WPushButton.new("Ok", dialog.contents)

    edit.enterPressed.connect(SLOT(dialog, :accept))
    ok.clicked.connect(SLOT(dialog, :accept))

    if dialog.exec == Wt::WDialog::Accepted
      @ed.setStatus("Welcome, " + edit.text)
    end
  end

  def createExtMessageBox
    mb = Wt::Ext::MessageBox.new

    mb.windowTitle = "Wt is magnificent"
    mb.text = "Isn't Wt the ruler of them all?"

    mb.buttons = Wt::Yes
    mb.finished.connect(SLOT(self, :deleteExtDialog))

    mb.show

    @extDialog = mb
  end

  def createExtDialog
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
    west.collapsible = true
    west.resize(Wt::WLength.new(100), Wt::WLength::Auto)
    west.layout = Wt::WFitLayout.new
    west.layout.addWidget(Wt::WText.new("This is a resizable and collapsible " \
                                        "panel"))
    layout.addWidget(west, Wt::WBorderLayout::West)

    center = Wt::Ext::Panel.new
    center.title = "Center"

    nestedLayout = Wt::WBorderLayout.new
    center.layout = nestedLayout

    nestedNorth = Wt::Ext::Panel.new
    nestedLayout.addWidget(nestedNorth, Wt::WBorderLayout::North)
    nestedNorth.resize(Wt::WLength::Auto, Wt::WLength.new(70))
    nestedNorth.layout.addWidget(
      Wt::WText.new("Ext Dialogs, like Wt Dialogs, can contain any widget. This " \
                "is a dialog with a layout manager. The left pane can be " \
                "resized."))

    nestedCenter = Wt::Ext::Panel.new
    nestedLayout.addWidget(nestedCenter, Wt::WBorderLayout::Center)
    nestedCenter.layout.addWidget(Wt::WText.new("This is simply WText, but " \
                                                "could have been any widget."))

    layout.addWidget(center, Wt::WBorderLayout::Center)

    d.show
    @extDialog = d
    @extDialog.finished.connect(SLOT(self, :deleteExtDialog))
  end

  def createExtProgress
    d = Wt::Ext::ProgressDialog.new("Please wait while calculating Pi ...", "Cancel", 0, 7)
    d.windowTitle = "Calculator"

    d.show

    for i in 0...7
      d.value = i
      $wApp.processEvents

      if !d.wasCanceled
        # Do some work ... 
        sleep(1000)
        sleep(1)
      else
        Wt::Ext::MessageBox.show("Operation cancelled",
                "It does not matter, Pi is overrated", Wt::Ok)
        break
      end
    end
  end

  def deleteExtDialog
    if @extDialog.result == Wt::Ext::Dialog::Accepted
      @ed.status = "Ext dialog accecpted"
    else
      @ed.status = "Ext dialog rejected"
    end
    # delete @extDialog
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
