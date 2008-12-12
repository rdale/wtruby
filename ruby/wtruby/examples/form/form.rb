=begin
 Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.

 See the LICENSE file for terms of use.

 Translated to Ruby by Richard Dale
=end

# formexample

# A simple Form.

# Shows how a simple form can made, with an emphasis on how
# to handle validation.

class Form < Wt::WTable

  def initialize(parent)
    super(parent)
  	createUI
  end

  def createUI
    row = 0
  
    # Title
    elementAt(row, 0).columnSpan = 3
    elementAt(row, 0).contentAlignment = Wt::AlignTop | Wt::AlignCenter
    elementAt(row, 0).padding = Wt::WLength.new(10)
    title = Wt::WText.new(tr("example.form"),
                elementAt(row, 0))
    title.decorationStyle.font.setSize(Wt::WFont::XLarge)
  
    # error messages
    row += 1
    elementAt(row, 0).columnSpan = 3
    @feedbackMessages = elementAt(row, 0)
    @feedbackMessages.padding = Wt::WLength.new(5)
  
    errorStyle = @feedbackMessages.decorationStyle
    errorStyle.foregroundColor = Wt::WColor.new(Wt::red)
    errorStyle.font.size = Wt::WFont::Smaller
    errorStyle.font.weight = Wt::WFont::Bold
    errorStyle.font.style = Wt::WFont::Italic
  
    # Name
    row += 1
    @nameEdit = Wt::WLineEdit.new(elementAt(row, 2))
    label = Wt::WLabel.new(tr("example.name"), elementAt(row, 0))
    label.buddy = @nameEdit
    @nameEdit.validator = Wt::WValidator.new(true)
    @nameEdit.enterPressed.connect(SLOT(self, :submit))

    # First name
    row += 1
    @firstNameEdit = Wt::WLineEdit.new(elementAt(row, 2))
    label = Wt::WLabel.new(tr("example.firstname"), elementAt(row,0))
    label.buddy = @firstNameEdit
  
    # Country
    row += 1
    @countryEdit = Wt::WComboBox.new(elementAt(row, 2))
    @countryEdit.addItem("")
    @countryEdit.addItem("Belgium")
    @countryEdit.addItem("Netherlands")
    @countryEdit.addItem("United Kingdom")
    @countryEdit.addItem("United States")
    label = Wt::WLabel.new(tr("example.country"), elementAt(row, 0))
    label.buddy = @countryEdit
    @countryEdit.validator = Wt::WValidator.new(true)
    @countryEdit.changed.connect(SLOT(self, :countryChanged))
  
    # City
    row += 1
    @cityEdit = Wt::WComboBox.new(elementAt(row, 2))
    @cityEdit.addItem(tr("example.choosecountry"))
    label = Wt::WLabel.new(tr("example.city"), elementAt(row, 0))
    label.buddy = @cityEdit
  
    # Birth date
    row += 1
  
    @birthDateEdit = Wt::WLineEdit.new(elementAt(row, 2))
    label = Wt::WLabel.new(tr("example.birthdate"), elementAt(row, 0))
    label.buddy = @birthDateEdit
    @birthDateEdit.setValidator(DateValidator.new(Date.new(1900, 1, 1),
                                Date.today))
    @birthDateEdit.validator.mandatory = true
  
    picker = Wt::WDatePicker.new( Wt::WText.new("..."),
                                  @birthDateEdit, true,
                                  elementAt(row, 2) )
  
    # Child count
    row += 1
    @childCountEdit = Wt::WLineEdit.new("0", elementAt(row, 2))
    label = Wt::WLabel.new( tr("example.childcount"),
                            elementAt(row, 0) )
    label.buddy = @childCountEdit
    @childCountEdit.validator = Wt::WIntValidator.new(0,30)
    @childCountEdit.validator.mandatory = true
  
    row += 1
    @remarksEdit = Wt::WTextArea.new(elementAt(row, 2))
    @remarksEdit.columns = 40
    @remarksEdit.rows = 5
    label = Wt::WLabel.new( tr("example.remarks"),
                            elementAt(row, 0) )
    label.buddy = @remarksEdit
  
    # Submit
    row += 1
    submit = Wt::WPushButton.new( tr("submit"),
                                  elementAt(row, 0) )
    submit.clicked.connect(SLOT(self, :submit))
    submit.setMargin(Wt::WLength.new(15), Wt::Top)
    elementAt(row, 0).columnSpan = 3
    elementAt(row, 0).contentAlignment = Wt::AlignTop | Wt::AlignCenter
  
    # Set column widths for label and validation icon
    elementAt(2, 0).resize(Wt::WLength.new(30, Wt::WLength::FontEx), Wt::WLength.new)
    elementAt(2, 1).resize(Wt::WLength.new(20), Wt::WLength.new)
  end

  def countryChanged
    @cityEdit.clear
    @cityEdit.addItem("")
    @cityEdit.currentIndex = -1
  
    case @countryEdit.currentIndex
    when 0:
    when 1:
      @cityEdit.addItem("Antwerp")
      @cityEdit.addItem("Brussels")
      @cityEdit.addItem("Oekene")
    when 2:
      @cityEdit.addItem("Amsterdam")
      @cityEdit.addItem("Den Haag")
      @cityEdit.addItem("Rotterdam")
    when 3:
      @cityEdit.addItem("London")
      @cityEdit.addItem("Bristol")
      @cityEdit.addItem("Oxford")
      @cityEdit.addItem("Stonehenge")
    when 4:
      @cityEdit.addItem("Boston")
      @cityEdit.addItem("Chicago")
      @cityEdit.addItem("Los Angelos")
      @cityEdit.addItem("New York")
    end   
  end

  # Validate a single form field.
  #
  # Checks the given field, and appends the given text to the error
  # messages on problems.
  #
  def checkValid(edit, text)
    if edit.validate != Wt::WValidator::Valid
      @feedbackMessages.addWidget(Wt::WText.new(text))
      @feedbackMessages.addWidget(Wt::WBreak.new)
      edit.label.decorationStyle.foregroundColor = Wt::WColor.new(Wt::red)
      edit.styleClass = "Wt-invalid"
  
      return false
    else
      edit.label.decorationStyle.foregroundColor = Wt::WColor.new
      edit.styleClass = ""
  
      return true
    end
  end

  # Validate the form, and return whether succesfull.
  #
  def validate
    @feedbackMessages.clear
    valid = true
  
    if !checkValid(@nameEdit, tr("error.name"))
      valid = false
    end
    if !checkValid(@countryEdit, tr("error.country"))
      valid = false
    end
    if !checkValid(@birthDateEdit, tr("error.birthdate"))
      valid = false
    end
    if !checkValid(@childCountEdit, tr("error.childcount"))
      valid = false
    end
  
    return valid
  end

  def submit
    if validate
      # do something useful with the data...
      name = @firstNameEdit.text + " " + @nameEdit.text
      remarks = @remarksEdit.text
      clear
  
      # WMessage with arguments is not yet implemented...
      Wt::WText.new(  "<p>Thank you, " + name +
                      ", for all this precious data.</p>", elementAt(0, 0) )
      
      if !remarks.empty?
        Wt::WText.new("<p>You had some remarks. Splendid !</p>", elementAt(0, 0))
      end
      $wApp.quit
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
