#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale

require 'wt'

#
# dialog Dialog example
#
#
# An example illustrating usage of Dialogs
#
class DialogExample < Wt::WApplication 
  def initialize(env)
    super(env)
    @messageBox = 0
    setTitle("Dialog example")
  
    Wt::WText.new("<h2>Wt dialogs example</h2>", root)
  
    textdiv = Wt::WContainerWidget.new(root)
    textdiv.styleClass = "text"
  
    Wt::WText.new("You can use Wt::WMessageBox for simple modal dialog boxes. <br />",
                  textdiv)
  
    buttons = Wt::WContainerWidget.new(root)
    buttons.styleClass = "buttons"
  
    button = Wt::WPushButton.new("One liner", buttons)
    button.clicked.connect(SLOT(self, :messageBox1))
  
    button = Wt::WPushButton.new("Comfortable ?", buttons)
    button.clicked.connect(SLOT(self, :messageBox2))
  
    button = Wt::WPushButton.new("Havoc!", buttons)
    button.clicked.connect(SLOT(self, :messageBox3))
  
    button = Wt::WPushButton.new("Discard", buttons)
    button.clicked.connect(SLOT(self, :messageBox4))
  
    button = Wt::WPushButton.new("Familiar", buttons)
    button.clicked.connect(SLOT(self, :custom))
  
    textdiv = Wt::WContainerWidget.new(root)
    textdiv.styleClass = "text"
  
    @status = Wt::WText.new("Go ahead...", textdiv)
  
    styleSheet.addRule(".buttons",
            "padding: 5px;")
    styleSheet.addRule(".buttons BUTTON",
            "padding-left: 4px; padding-right: 4px;" \
            "margin-top: 4px; display: block")
    styleSheet.addRule(".text", "padding: 4px 8px")
  end
  
  def messageBox1
    Wt::WMessageBox::show("Information",
          "Enjoy displaying messages with a one-liner.", Wt::Ok)
    setStatus("Ok'ed")
  end
  
  def messageBox2
    @messageBox = Wt::WMessageBox.new(  "Question",
                                        "Are you getting comfortable ?",
                                        Wt::NoIcon, Wt::Yes | Wt::No | Wt::Cancel )
  
    @messageBox.buttonClicked.connect(SLOT(self, :messageBoxDone))
    @messageBox.show
    end
  
    def messageBox3
      result = Wt::WMessageBox::show( "Confirm", "About to wreak havoc... Continue ?",
                                      Wt::Ok | Wt::Cancel )
  
      if result == Wt::Ok
        setStatus("Wreaking havoc.")
      else
        setStatus("Cancelled!")
      end
    end
  
    def messageBox4
      @messageBox = Wt::WMessageBox.new(  "Your work",
                                          "Your work is not saved",
                                          Wt::NoIcon, Wt::NoButton)
    
      @messageBox.addButton("Cancel modifications", Wt::Ok)
      @messageBox.addButton("Continue modifying work", Wt::Cancel) 
      @messageBox.buttonClicked.connect(SLOT(self, :messageBoxDone))
      @messageBox.show
    end
  
  def messageBoxDone(result)
    case result
    when Wt::Ok:
      setStatus("Ok'ed")
    when Wt::Cancel:
      setStatus("Cancelled!")
    when Wt::Yes:
      setStatus("Me too!")
    when Wt::No:
      setStatus("Me neither!")
    when
      setStatus("Unkonwn result?")
    end
  
    @messageBox = nil
  end
  
  def custom
    dialog = Wt::WDialog.new("Personalia")
  
    Wt::WText.new("Enter your name: ", dialog.contents)
    edit = Wt::WLineEdit.new(dialog.contents)
    Wt::WBreak.new(dialog.contents)
    ok = Wt::WPushButton.new("Ok", dialog.contents)
  
    edit.enterPressed.connect(SLOT(dialog, :accept))
    ok.clicked.connect(SLOT(dialog, :accept))
  
    if dialog.exec == Wt::WDialog::Accepted
      setStatus("Welcome, " + edit.text)
    end
  end
  
  def setStatus(result)
    @status.text = result
  end
end

Wt::WRun(ARGV) do |env|
  DialogExample.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
