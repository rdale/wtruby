#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class Validators < ControlsWidget

  def initialize(ed)
    super(ed, false)
    topic("WValidator", self)

    @fields = []
    Wt::WText.new(tr("validators-intro"), self)

    Wt::WText.new("<h2>Validator types</h2>", self)
    table = Wt::WTable.new(self)
    table.styleClass = "validators"

    Wt::WText.new("WIntValidator: input is mandatory and in range [50 - 100]",
              table.elementAt(0, 0))
    le = Wt::WLineEdit.new(table.elementAt(0, 1))
    iv = Wt::WIntValidator.new(50, 100)
    iv.mandatory = true
    le.validator = iv
    @fields.push([le, Wt::WText.new("", table.elementAt(0, 2))])

    Wt::WText.new("WDoubleValidator: range [-5.0 to 15.0]", table.elementAt(1, 0))
    le = Wt::WLineEdit.new(table.elementAt(1, 1))
    le.setValidator(Wt::WDoubleValidator.new(-5, 15))
    @fields.push([le, Wt::WText.new("", table.elementAt(1, 2))])

    Wt::WText.new("WDateValidator, default format \"yyyy-MM-dd\"", table.elementAt(2, 0))
    le = Wt::WLineEdit.new(table.elementAt(2, 1))
    le.validator = Wt::WDateValidator.new
    @fields.push([le, Wt::WText.new("", table.elementAt(2, 2))])

    Wt::WText.new("WDateValidator, format \"dd-MM-yy\"", table.elementAt(3, 0))
    le = Wt::WLineEdit.new(table.elementAt(3, 1))
    le.validator = Wt::WDateValidator.new("dd-MM-yy")
    @fields.push([le, Wt::WText.new("", table.elementAt(3, 2))])

    Wt::WText.new("WDateValidator, format \"yy-MM-dd\", range 1 to 15 October 08",
              table.elementAt(4, 0))
    le = Wt::WLineEdit.new(table.elementAt(4, 1))
    le.setValidator(Wt::WDateValidator.new("yy-MM-dd", Wt::WDate.new(2008, 10, 1),
                                        Wt::WDate.new(2008, 10, 15)))
    @fields.push([le, Wt::WText.new("", table.elementAt(4, 2))])

    Wt::WText.new("WLengthValidator, 6 to 11 characters", table.elementAt(5, 0))
    le = Wt::WLineEdit.new(table.elementAt(5, 1))
    le.setValidator(Wt::WLengthValidator.new(6, 11))
    @fields.push([le, Wt::WText.new("", table.elementAt(5, 2))])

    ipRegexp = "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    Wt::WText.new("WRegExpValidator, IP address", table.elementAt(6, 0))
    le = Wt::WLineEdit.new(table.elementAt(6, 1))
    le.validator = Wt::WRegExpValidator.new(ipRegexp)
    @fields.push([le, Wt::WText.new("", table.elementAt(6, 2))])
    
    Wt::WText.new("<p>The IP address validator regexp is: " + ipRegexp + "</p>",
              self)

    Wt::WText.new("<p>All WFormWidgets can have validators, so also the " \
              "WTextArea. Type up to 50 characters in the box below</p>", self)
    ta = Wt::WTextArea.new(self)
    ta.setValidator(Wt::WLengthValidator.new(0, 50))
    @fields.push([ta, Wt::WText.new("", self)])


    Wt::WText.new("<h2>Server-side validation</h2>", self)
    Wt::WText.new("<p>The button below causes the server to validate all " \
              "input fields above server-side, and puts the state of the " \
              "validation on the right of every widget: " \
              "<ul>" \
              " <li>Valid: data is valid</li>" \
              " <li>Invalid: data is invalid</li>" \
              " <li>InvalidEmpty: field is empty, but was indicated to be " \
              "     mandatory</li>" \
              "</ul></p>", self)
    pb = Wt::WPushButton.new("Validate server-side", self)
    pb.clicked.connect(SLOT(self, :validateServerside))
    ed.mapConnect(pb.clicked, "WPushButton: request server-side validation")
  end

  def validateServerside
    for i in 0...@fields.length
      case @fields[i][0].validate
      when Wt::WValidator::Valid
        @fields[i][1].text = "Valid"
      when Wt::WValidator::InvalidEmpty
        @fields[i][1].text = "InvalidEmpty"
      when Wt::WValidator::Invalid
        @fields[i][1].text = "Invalid"
      end
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
