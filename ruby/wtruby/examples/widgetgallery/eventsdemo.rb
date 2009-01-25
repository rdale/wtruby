#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

$: << '../dragdrop'
require 'dragexample.rb'

class EventsDemo < ControlsWidget

  def initialize(ed)
    super(ed, true)
    @keyEventRepeatCounter = 0
    Wt::WText.new(tr("events-intro"), self)
  end

  def populateSubMenu(menu)
    menu.addItem("WKeyEvent", wKeyEvent)
    menu.addItem("WMouseEvent", wMouseEvent)
    menu.addItem("WDropEvent", wDropEvent)
  end

  def wKeyEvent
    result = Wt::WContainerWidget.new

    topic("WKeyEvent", result)
    Wt::WText.new(tr("events-WKeyEvent-1"), result)
    l = Wt::WLineEdit.new(result)
    l.textSize = 50
    l.keyWentUp.connect(SLOT(self, :showKeyWentUp))
    l.keyWentDown.connect(SLOT(self, :showKeyWentDown))
    
    Wt::WText.new(tr("events-WKeyEvent-2"), result)
    l = Wt::WLineEdit.new(result)
    l.textSize = 50
    l.keyPressed.connect(SLOT(self, :showKeyPressed))
    
    Wt::WText.new(tr("events-WKeyEvent-3"), result)
    l = Wt::WLineEdit.new(result)
    l.textSize = 50
    l.enterPressed.connect(SLOT(self, :showEnterPressed))
    l.escapePressed.connect(SLOT(self, :showEscapePressed))
    Wt::WBreak.new(result)
    Wt::WText.new("Last event: ", result)
    @keyEventType = Wt::WText.new(result)
    Wt::WBreak.new(result)
    @keyEventDescription = Wt::WText.new(result)

    return result
  end

  def wMouseEvent
    result = Wt::WContainerWidget.new

    topic("WMouseEvent", result)
    Wt::WText.new(tr("events-WMouseEvent"), result)
    c = Wt::WContainerWidget.new(result)
    hlayout = Wt::WHBoxLayout.new
    c.layout = hlayout
    l = Wt::WContainerWidget.new
    r = Wt::WContainerWidget.new
    Wt::WText.new("clicked<br/>doubleClicked<br/>mouseWentOut<br/>mouseWentOver", l)
    Wt::WText.new("mouseWentDown<br/>mouseWentUp<br/>mouseMoved", r)
    hlayout.addWidget(l)
    hlayout.addWidget(r)
    c.resize(Wt::WLength.new(600), Wt::WLength.new(300))
    l.decorationStyle.backgroundColor = Wt::WColor.new(Wt::gray)
    r.decorationStyle.backgroundColor = Wt::WColor.new(Wt::gray)
    # prevent that firefox interprets drag as drag&drop action
    l.styleClass = "unselectable"
    r.styleClass = "unselectable"
    l.clicked.connect(SLOT(self, :showClicked))
    l.doubleClicked.connect(SLOT(self, :showDoubleClicked))
    l.mouseWentOut.connect(SLOT(self, :showMouseWentOut))
    l.mouseWentOver.connect(SLOT(self, :showMouseWentOver))
    r.mouseMoved.connect(SLOT(self, :showMouseMoved))
    r.mouseWentUp.connect(SLOT(self, :showMouseWentUp))
    r.mouseWentDown.connect(SLOT(self, :showMouseWentDown))
    Wt::WBreak.new(result)
    Wt::WText.new("Last event: ", result)
    @mouseEventType = Wt::WText.new(result)
    Wt::WBreak.new(result)
    @mouseEventDescription = Wt::WText.new(result)

    return result
  end

  def wDropEvent
    result = Wt::WContainerWidget.new

    topic("WDropEvent", result)
    Wt::WText.new(tr("events-WDropEvent"), result)
    DragExample.new(result)

    return result
  end

  def wMouseEventButtonToString(b)
    case b
    when Wt::WMouseEvent::LeftButton:
      return "LeftButton"
    when Wt::WMouseEvent::RightButton:
      return "LeftButton"
    when Wt::WMouseEvent::MiddleButton:
      return "LeftButton"
    else
      return "Unknown Button"
    end
  end

  def keyToString(k)
    case k
    when Wt::Key_unknown : return "Key_unknown"
    when Wt::Key_Enter : return "Key_Enter"
    when Wt::Key_Tab : return "Key_Tab"
    when Wt::Key_Backspace : return "Key_Backspace"
    when Wt::Key_Shift : return "Key_Shift"
    when Wt::Key_Control : return "Key_Control"
    when Wt::Key_Alt : return "Key_Alt"
    when Wt::Key_PageUp : return "Key_PageUp"
    when Wt::Key_PageDown : return "Key_PageDown"
    when Wt::Key_End : return "Key_End"
    when Wt::Key_Home : return "Key_Home"
    when Wt::Key_Left : return "Key_Left"
    when Wt::Key_Up : return "Key_Up"
    when Wt::Key_Right : return "Key_Right"
    when Wt::Key_Down : return "Key_Down"
    when Wt::Key_Insert : return "Key_Insert"
    when Wt::Key_Delete : return "Key_Delete"
    when Wt::Key_Escape : return "Key_Escape"
    when Wt::Key_F1 : return "Key_F1"
    when Wt::Key_F2 : return "Key_F2"
    when Wt::Key_F3 : return "Key_F3"
    when Wt::Key_F4 : return "Key_F4"
    when Wt::Key_F5 : return "Key_F5"
    when Wt::Key_F6 : return "Key_F6"
    when Wt::Key_F7 : return "Key_F7"
    when Wt::Key_F8 : return "Key_F8"
    when Wt::Key_F9 : return "Key_F9"
    when Wt::Key_F10 : return "Key_F10"
    when Wt::Key_F11 : return "Key_F11"
    when Wt::Key_F12 : return "Key_F12"
    when Wt::Key_Space : return "Key_Space"
    when Wt::Key_A : return "Key_A"
    when Wt::Key_B : return "Key_B"
    when Wt::Key_C : return "Key_C"
    when Wt::Key_D : return "Key_D"
    when Wt::Key_E : return "Key_E"
    when Wt::Key_F : return "Key_F"
    when Wt::Key_G : return "Key_G"
    when Wt::Key_H : return "Key_H"
    when Wt::Key_I : return "Key_I"
    when Wt::Key_J : return "Key_J"
    when Wt::Key_K : return "Key_K"
    when Wt::Key_L : return "Key_"
    when Wt::Key_M : return "Key_M"
    when Wt::Key_N : return "Key_N"
    when Wt::Key_O : return "Key_O"
    when Wt::Key_P : return "Key_P"
    when Wt::Key_Q : return "Key_Q"
    when Wt::Key_R : return "Key_R"
    when Wt::Key_S : return "Key_S"
    when Wt::Key_T : return "Key_T"
    when Wt::Key_U : return "Key_U"
    when Wt::Key_V : return "Key_V"
    when Wt::Key_W : return "Key_W"
    when Wt::Key_X : return "Key_X"
    when Wt::Key_Y : return "Key_Y"
    when Wt::Key_Z : return "Key_Z"
    end
  end

  def mouseEventCoordinatesToString(c)
    return "%s, %s" % [c.x, c.y]
  end

  def modifiersToString(m)
    o = ""
    if (Wt::ShiftModifier & m) != 0
      o << "Shift "
    end
    if (Wt::ControlModifier & m) != 0
      o << "Control "
    end
    if (Wt::AltModifier & m) != 0
      o << "Alt "
    end
    if (Wt::MetaModifier & m) != 0
      o << "Meta "
    end
    if m == 0 
      o << "No modifiers"
    end
    return o
  end

  def setKeyType(type, e = nil)
    repeatString = ""
    if @lastKeyType == type
      @keyEventRepeatCounter += 1
      repeatString = " (" + @keyEventRepeatCounter.to_s + " times)"
    else
      @lastKeyType = type
      @keyEventRepeatCounter = 0
    end
    @keyEventType.text = type + repeatString
    if e
      describe(e)
    else
      @keyEventDescription.text = ""
    end
  end

  def showKeyWentUp(e)
    setKeyType("keyWentUp", e)
  end

  def showKeyWentDown(e)
    setKeyType("keyWentDown", e)
  end

  def showKeyPressed(e)
    setKeyType("keyPressed", e)
  end

  def showEnterPressed
    setKeyType("enterPressed")
  end

  def showEscapePressed
    setKeyType("escapePressed")
  end

  def describe(e)
    if e.kind_of?(Wt::WKeyEvent)
      describeWKeyEvent(e)
    elsif e.kind_of?(Wt::WMouseEvent)
      describeWMouseEvent(e)
    end
  end

  def describeWKeyEvent(e)
    ss = "Key: " << keyToString(e.key) << "<br/>" <<
         "Modifiers: " << modifiersToString(e.modifiers) << "<br/>" <<
         "Char code: " << e.charCode.to_s << "<br/>" <<
         "text: " << e.text << "<br/>"
    @keyEventDescription.text = ss
  end

  def showClicked(e)
    @mouseEventType.text = "clicked"
    describe(e)
  end

  def showDoubleClicked(e)
    @mouseEventType.text = "doubleClicked"
    describe(e)
  end

  def showMouseWentOut(e)
    @mouseEventType.text = "mouseWentOut"
    describe(e)
  end

  def showMouseWentOver(e)
    @mouseEventType.text = "mouseWentOver"
    describe(e)
  end

  def showMouseMoved(e)
    @mouseEventType.text = "mouseMoved"
    describe(e)
  end

  def showMouseWentUp(e)
    @mouseEventType.text = "mouseWentUp"
    describe(e)
  end

  def showMouseWentDown(e)
    @mouseEventType.text = "mouseWentDown"
    describe(e)
  end

  def describeWMouseEvent(e)
    ss = "Button: " << wMouseEventButtonToString(e.button) << "<br/>" <<
         "Modifiers: " << modifiersToString(e.modifiers) << "<br/>" <<
         "Document coordinates: " << mouseEventCoordinatesToString(e.document) << "<br/>" <<
         "Window coordinates: " << mouseEventCoordinatesToString(e.window) << "<br/>" <<
         "Screen coordinates: " << mouseEventCoordinatesToString(e.screen) << "<br/>" <<
         "Widget coordinates: " << mouseEventCoordinatesToString(e.widget) << "<br/>" <<
         "DragDelta coordinates: " << mouseEventCoordinatesToString(e.dragDelta) << "<br/>"
    @mouseEventDescription.text = ss
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
