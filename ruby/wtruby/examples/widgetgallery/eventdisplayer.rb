#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class EventDisplayer < Wt::WContainerWidget
  # connects the invocation of the given signal to the display of the
  # string
  # connects the invocation of the given signal to the display of the
  # given string, concatenated with the WText parameter of the signal.
  # Print a message on the displayer


  def initialize(parent)
    # super(parent)
    super()
    @text = Wt::WText.new("Events will be shown here.", self)
    @map = Wt::WSignalMapper.new(self)
    @mapWString = Wt::WSignalMapper.new(self)
    setStyleClass("events")

    @map.mapped.connect(SLOT(self, :showSignal))
    @mapWString.mapped.connect(SLOT(self, :showWStringSignal))
  end

  def mapConnect(signal, data)
    @map.mapConnect(signal, data)
  end

  def mapConnectWString(signal, data)
    @mapWString.mapConnect1(signal, data)
  end

  def showSignal(str)
    showEvent("Last activated signal: " + str)
  end

  def showWStringSignal(str, wstr)
    showEvent("Last activated signal: " + str + wstr)
  end

  def setStatus(msg)
    showEvent("Last status message: " + msg)
  end

  def showEvent(str)
    if str == @lastEventStr
      @eventCount += 1
      @text.setText(str + " (" + @eventCount.to_s + " times)")
    else
      @lastEventStr = str
      @eventCount = 1
      @text.text = str
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
