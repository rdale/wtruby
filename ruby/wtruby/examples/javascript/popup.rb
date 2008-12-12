#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale


#*
# javascript
#
# A JavaScript based popup window, encapsulating the Javascript
#         functions alert(), confirm(), and prompt().
#
# Use one of the create static methods to create a popup. This will not
# display the popup, until either the show slot is triggered from an
# event handler, or is executed using it's exec() method.
#
# When the user closes the popup, either the okPressed or cancelPressed
# signal is emitted. For a prompt dialog, the value is passed as a parameter
# to the okPressed signal.
#
class Popup < Wt::WObject
  attr_reader :okPressed, :cancelPressed, :defaultValue, :show

  Confirm = 0
  Alert = 1
  Prompt = 2

  #
  # Popup constructor.
  def initialize(t, message, defaultValue, parent)
    super(parent)
    @okPressed = Wt::JSignal1.new(self, "ok")
    @cancelPressed = Wt::JSignal.new(self, "cancel")
    @t = t
    @message = message
    @defaultValue = defaultValue
    @show = Wt::JSlot.new
    setJavaScript
  end

  def setJavaScript
    #
    # Sets the JavaScript code.
    #
    # Notice how Wt.emit is used to emit the @okPressed or @cancelPressed
    # signal, and how arguments may be passed to it, matching the number and
    # type of arguments in the JSignal definition.
    #
    case @t
    when Confirm:
      @show.javaScript =  "function(){ if (confirm('" + @message + "')) {" \
                          "  Wt.emit('" + id + "','" + @okPressed.name + "', '');" \
                          "} else {" \
                          "  Wt.emit('" + id + "','" + @cancelPressed.name + "');" \
                          "}}"
    when Alert:
      @show.javaScript =  "function(){ alert('" + @message + "');" \
                          "Wt.emit('" + id + "','" + @okPressed.name + "', '');}"
    when Prompt:
      @show.javaScript =  "function(){var n = prompt('" + @message + "', '" +
                          @defaultValue + "');" \
                          "if (n != null) {" \
                          "  Wt.emit('" + id + "','" + @okPressed.name + "', n);" \
                          "} else {" \
                          "  Wt.emit('" + id + "','" + @cancelPressed.name + "');" \
                          "}}" 
    end
  end

  def message=(message)
    @message = message
    setJavaScript
  end

  def defaultValue=(defaultValue)
    @defaultValue = defaultValue
    setJavaScript
  end

  def self.createConfirm(message, parent)
    return Popup.new(Confirm, message, "", parent)
  end

  def self.createAlert(message, parent)
    return Popup.new(Alert, message, "", parent)
  end

  def self.createPrompt(message, defaultValue, parent)
    return Popup.new(Prompt, message, defaultValue, parent)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
