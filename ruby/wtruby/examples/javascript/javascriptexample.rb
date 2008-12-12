#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'popup.rb'

# Javascript - Wt interaction example
#
# An example showing how to interact custom JavaScript with Wt
#         stuff
#
class JavascriptExample < Wt::WApplication

  def initialize(env)
    super(env)
    setTitle("Javascript example")

    # Create a popup for prompting the amount of money, and connect the
    # okPressed button to the slot for setting the amount of money.
    #
    # Note that the input provided by the user in the prompt box is passed as
    # an argument to the slot.
    @promptAmount = Popup.createPrompt("How much do you want to pay?", "", self)
    @promptAmount.okPressed.connect(SLOT(self, :setAmount))

    # Create a popup for confirming the payment.
    #
    # Since a confirm popup does not allow input, we ignore the
    # argument carrying the input (which will be empty anyway).
    @confirmPay = Popup.createConfirm("", self)
    @confirmPay.okPressed.connect(SLOT(self, :confirmed))

    Wt::WText.new("<h2>Wt Javascript example</h2>" \
      "<p>Wt makes abstraction of Javascript, and therefore allows you" \
      " to develop web applications without any knowledge of Javascript," \
      " and which are not dependent on Javascript." \
      " However, Wt does allow you to add custom Javascript code:</p>" \
      " <ul>" \
      "   <li>To call custom JavaScript code from an event handler, " \
      "connect the Wt::EventSignal to a Wt::JSlot.</li>" \
      "   <li>To call C++ code from custom JavaScript, use " \
      "Wt.emit to emit a Wt::JSignal.</li>" \
      "   <li>To call custom JavaScript code from C++, use " \
      "Wt::WApplication::doJavascript or Wt::JSlot::exec.</li>" \
      " </ul>" \
      "<p>This simple application shows how to interact between C++ and" \
      " JavaScript using the JSlot and JSignal classes.</p>", root)

    @currentAmount = Wt::WText.new("Current amount: $" + @promptAmount.defaultValue, root)
  
    amountButton = Wt::WPushButton.new("Change ...", root)
    amountButton.setMargin(Wt::WLength.new(10), Wt::WWidget::Left | Wt::WWidget::Right)
  
    Wt::WBreak.new(root)
  
    confirmButton = Wt::WPushButton.new("Pay now.", root)
    confirmButton.setMargin(Wt::WLength.new(10), Wt::WWidget::Top | Wt::WWidget::Bottom)
  
    # Connect the event handlers to a JSlot: this will execute the JavaScript
    # immediately, without a server round trip.
    amountButton.clicked.connect(@promptAmount.show)
    confirmButton.clicked.connect(@confirmPay.show)
  
    # Set the initial amount
    setAmount("1000")
  end

  def setAmount(amount)
    # Change the confirmation message to include the amount.
    @confirmPay.message = "Are you sure you want to pay $" + amount + " ?"
  
    # Change the default value for the prompt.
    @promptAmount.defaultValue = amount
  
    # Change the text that shows the current amount.
    @currentAmount.text = "Current amount: $" + @promptAmount.defaultValue
  end

  def confirmed
    Wt::WText.new("<br/>Just paid $" + @promptAmount.defaultValue + ".", root)
  end
end

Wt::WRun(ARGV) do |env|
  JavascriptExample.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
