#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
class FormWidgets < ControlsWidget

  def initialize(ed)
    super(ed, true)
    Wt::WText.new(tr("formwidgets-intro"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("WPushButton", wPushButton)
    menu.addItem("WCheckBox", wCheckBox)
    menu.addItem("WRadioButton", wRadioButton)
    menu.addItem("WComboBox", wComboBox)
    menu.addItem("WSelectionBox", wSelectionBox)
    menu.addItem("WLineEdit", wLineEdit)
    menu.addItem("WTextArea", wTextArea)
    menu.addItem("WCalendar", wCalendar)
    menu.addItem("WDatePicker", wDatePicker)
    menu.addItem("WInPlaceEdit", wInPlaceEdit)
    menu.addItem("WSuggestionPopup", wSuggestionPopup)
    menu.addItem("WTextEdit", deferCreate(:wTextEdit, self))
    menu.addItem("WFileUpload", wFileUpload)
  end

  def wPushButton
    result = Wt::WContainerWidget.new

    topic("WPushButton", result)
    Wt::WText.new(tr("formwidgets-WPushButton"), result)
    pb = Wt::WPushButton.new("Click me!", result)
    @ed.mapConnect(pb.clicked, "WPushButton click")

    Wt::WText.new(tr("formwidgets-WPushButton-more"), result)
    pb = Wt::WPushButton.new("Try to click me...", result)
    pb.enabled = false
    
    return result
  end

  def wCheckBox
    result = Wt::WContainerWidget.new

    topic("WCheckBox", result)
    Wt::WText.new(tr("formwidgets-WCheckBox"), result)
    cb = Wt::WCheckBox.new("Check me!", result)
    cb.checked = true
    @ed.mapConnect(cb.checked, "'Check me!' checked")
    Wt::WBreak.new(result)
    cb = Wt::WCheckBox.new("Check me too!", result)
    @ed.mapConnect(cb.checked, "'Check me too!' checked")

    return result
  end

  def wRadioButton
    result = Wt::WContainerWidget.new

    topic("WRadioButton", result)
    Wt::WText.new(tr("formwidgets-WRadioButton"), result)
    rb = Wt::WRadioButton.new("Radio me!", result)
    @ed.mapConnect(rb.checked, "'Radio me!' checked (not in buttongroup)")
    Wt::WBreak.new(result)
    rb = Wt::WRadioButton.new("Radio me too!", result)
    @ed.mapConnect(rb.checked, "'Radio me too!' checked " \
                  "(not in buttongroup)")
    
    Wt::WText.new(tr("formwidgets-WRadioButton-group"), result)
    wgb = Wt::WButtonGroup.new(result)
    rb = Wt::WRadioButton.new("Radio me!", result)
    @ed.mapConnect(rb.checked, "'Radio me!' checked")
    wgb.addButton(rb)
    Wt::WBreak.new(result)
    rb = Wt::WRadioButton.new("No, radio me!", result)
    @ed.mapConnect(rb.checked, "'No, Radio me!' checked")
    wgb.addButton(rb)
    Wt::WBreak.new(result)
    rb = Wt::WRadioButton.new("Nono, radio me!", result)
    @ed.mapConnect(rb.checked, "'Nono, radio me!' checked")
    wgb.addButton(rb)

    wgb.selectedButtonIndex = 0

    return result
  end

  def wComboBox
    result = Wt::WContainerWidget.new

    topic("Wt::WComboBox", result)
    Wt::WText.new(tr("formwidgets-WComboBox"), result)
    cb = Wt::WComboBox.new(result)
    cb.addItem("Heavy")
    cb.addItem("Medium")
    cb.addItem("Light")
    cb.currentIndex = 1
    @ed.mapConnectWString(cb.sactivated, "WComboBox activation: ")

    Wt::WText.new(tr("formwidgets-WComboBox-model"), result)

    return result
  end

  def wSelectionBox
    result = Wt::WContainerWidget.new

    topic("WSelectionBox", result)
    Wt::WText.new(tr("formwidgets-WSelectionBox"), result)
    sb1 = Wt::WSelectionBox.new(result)
    sb1.addItem("Heavy")
    sb1.addItem("Medium")
    sb1.addItem("Light")
    sb1.currentIndex = 1
    @ed.mapConnectWString(sb1.sactivated, "WSelectionBox activation: ")
    Wt::WText.new("<p>... or multiple options (use shift and/or ctrl-click " \
              "to select your pizza toppings)</p>", result)
    sb2 = Wt::WSelectionBox.new(result)
    sb2.addItem("Bacon")
    sb2.addItem("Cheese")
    sb2.addItem("Mushrooms")
    sb2.addItem("Green peppers")
    sb2.addItem("Red peppers")
    sb2.addItem("Ham")
    sb2.addItem("Pepperoni")
    sb2.addItem("Turkey")
    sb2.selectionMode = Wt::ExtendedSelection
    selection = []
    selection.push(1)
    selection.push(2)
    selection.push(5)
    sb2.selectedIndexes = selection
    @ed.mapConnect(sb2.changed, "WSelectionBox 2 changed")

    Wt::WText.new(tr("formwidgets-WSelectionBox-model"), result)
    
    return result
  end

  def wLineEdit
    result = Wt::WContainerWidget.new

    topic("WLineEdit", result)
    Wt::WText.new(tr("formwidgets-WLineEdit"), result)
    le = Wt::WLineEdit.new("Edit me", result)
    @ed.mapConnect(le.keyWentUp, "Line edit keyWentUp")

    Wt::WText.new("<p>The WLineEdit on the following line reacts on the " \
              "enter button:</p>", result)

    le = Wt::WLineEdit.new("Press enter", result)
    @ed.mapConnect(le.enterPressed, "Line edit enterPressed")

    Wt::WText.new(tr("formwidgets-WLineEdit-more"), result)

    return result
  end

  def wTextArea
    result = Wt::WContainerWidget.new

    topic("WTextArea", result)
    Wt::WText.new(tr("formwidgets-WTextArea"), result)

    ta = Wt::WTextArea.new(result)
    ta.columns = 80
    ta.rows = 15
    ta.text = tr("formwidgets-WTextArea-contents")
    @ed.mapConnect(ta.changed, "Text areax changed")
  
    Wt::WText.new(tr("formwidgets-WTextArea-related"), result)

    return result
  end

  def wCalendar
    result = Wt::WContainerWidget.new

    topic("WCalendar", result)
    Wt::WText.new(tr("formwidgets-WCalendar"), result)
    c = Wt::WCalendar.new(false, result)
    @ed.mapConnect(c.selectionChanged, "First calendar selectionChanged")
    Wt::WText.new("<p>A flag indicates if multiple dates can be selected...</p>",
              result)
    c2 = Wt::WCalendar.new(false, result)
    c2.multipleSelection = true
    @ed.mapConnect(c2.selectionChanged, "Second calendar selectionChanged")

    return result
  end

  def wDatePicker
    result = Wt::WContainerWidget.new

    topic("WDatePicker", result)
    Wt::WText.new("<p>The WDatePicker allows the entry of a date.</p>",
              result)
    le1 = Wt::WLineEdit.new(result)
    b1 = Wt::WPushButton.new("...")
    dp = Wt::WDatePicker.new(b1, le1, false, result)
    @ed.mapConnect(le1.changed, "WDatePicker 1 changed")
    Wt::WText.new("(format " + dp.format + ")", result)
    Wt::WBreak.new(result)
    le2 = Wt::WLineEdit.new(result)
    b2 = Wt::WPushButton.new("...")
    dp2 = Wt::WDatePicker.new(b2, le2, false, result)
    dp2.format = "dddd MMMM d yyyy"
    Wt::WText.new("(format " + dp2.format + ")", result)
    
    le1.textSize = 30
    le2.textSize = 30
    @ed.mapConnect(le2.changed, "WDatePicker 2 changed")

    return result
  end

  def wInPlaceEdit
    result = Wt::WContainerWidget.new

    topic("WInPlaceEdit", result)
    Wt::WText.new("<p>This widget allows you to edit a string by clicking " \
              "on it. The text changes in a WLineEdit while editing.</p>",
              result)
    Wt::WText.new("Try it here: ", result)
    ipe = Wt::WInPlaceEdit.new("This is editable text", result)
    ipe.styleClass = "in-place-edit"
    @ed.mapConnectWString(ipe.valueChanged, "In place edit valueChanged: ")

    return result
  end

  def wSuggestionPopup
    result = Wt::WContainerWidget.new

    topic("WSuggestionPopup", result)
    Wt::WText.new(tr("formwidgets-WSuggestionPopup"), result)

    # options for email address suggestions
    contactOptions = Wt::WSuggestionPopup::Options.new do |opt|
      opt.highlightBeginTag = '<span class="highlight">'
      opt.highlightEndTag = '</span>'
      opt.listSeparator = ?,                        # for multiple addresses
      opt.whitespace = ' \n'
      opt.wordSeparators = '-., "@\n;'              # within an address
      opt.appendReplacedText = ", "                 # prepare next email address
    end

    sp = Wt::WSuggestionPopup.new(Wt::WSuggestionPopup.generateMatcherJS(contactOptions),
                          Wt::WSuggestionPopup.generateReplacerJS(contactOptions),
                          result)
    le = Wt::WLineEdit.new(result)
    le.textSize = 50
    le.inline = false
    sp.forEdit(le)
    sp.addSuggestion("John Tech <techie@mycompany.com>",
                      "John Tech <techie@mycompany.com>")
    sp.addSuggestion("Johnny Cash <cash@mycompany.com>", 
                      "Johnny Cash <cash@mycompany.com>")
    sp.addSuggestion("John Rambo <rambo@mycompany.com>",
                      "John Rambo <rambo@mycompany.com>")
    sp.addSuggestion("Johanna Tree <johanna@mycompany.com>",
                      "Johanna Tree <johanna@mycompany.com>")
    sp.styleClass = "suggest"
    
    return result
  end

  def wTextEdit
    result = Wt::WContainerWidget.new

    topic("WTextEdit", result)
    Wt::WText.new("<p>The WTextEdit is a full-featured editor for rich text " \
              "editing. It is based on the TinyMCE editor, which must be " \
              "downloaded separately from its author's website. The TinyMCE " \
              "toolbar layout and plugins can be configured through Wt's " \
              "interface. The default, shown below, covers only a small " \
              "portion of TinyMCE's capabilities.</p>", result)
    te = Wt::WTextEdit.new(result)
    @ed.mapConnect(te.changed, "Text edit changed")

    return result
  end

  def wFileUpload
    result = Wt::WContainerWidget.new

    topic("WFileUpload", result)
    Wt::WText.new("<p>WFileUpload is a widget to upload a file through the " \
              "browser from the client to the server where Wt is running</p>",
              result)
    fu = Wt::WFileUpload.new(result)
    fu.changed.connect(SLOT(fu, :upload))
    @ed.mapConnect(fu.changed, "File upload changed")
    @ed.mapConnect(fu.uploaded, "File upload finished")
    Wt::WText.new("<p>The file is stored in a temporary file at the server. The " \
              "filename at the client side, the temporary file name at the " \
              "server and the status of the upload can be queried from the " \
              "widget. Normally, the temporary file is deleted when the widget " \
              "is destroyed. File uploads can be started in the background " \
              "by connecting the WFfileUpload's changed signal to it's own " \
              "upload slot.</p>", result)

    return result
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
