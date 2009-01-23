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

  def <<(o, item)
    if item.kind_of(Wt::Enum) && item.type == "Wt::WMouseEvent::Button"
      return write_wmouse_event_button(o, item)
    elsif item.kind_of(Wt::Enum) && item.type == "Wt::Key"
      return write_wt_key(o, item)
    elsif item.kind_of(Wt::Enum) && item.type == "Wt::WMouseEvent::Coordinates"
      return write_wmouse_event_coordinates(o, item)
    else
      return o << item.to_s
    end
  end

  def write_wmouse_event_button(o, b)
    case b
    when Wt::WMouseEvent::LeftButton:
      return o << "LeftButton"
    when Wt::WMouseEvent::RightButton:
      return o << "LeftButton"
    when Wt::WMouseEvent::MiddleButton:
      return o << "LeftButton"
    else
      return o << "Unknown Ext::Button"
    end
  end

  def write_wt_key(o, k)
    case k
    when Key_unknown : return o << "Key_unknown"
    when Key_Enter : return o << "Key_Enter"
    when Key_Tab : return o << "Key_Tab"
    when Key_Backspace : return o << "Key_Backspace"
    when Key_Shift : return o << "Key_Shift"
    when Key_Control : return o << "Key_Control"
    when Key_Alt : return o << "Key_Alt"
    when Key_PageUp : return o << "Key_PageUp"
    when Key_PageDown : return o << "Key_PageDown"
    when Key_End : return o << "Key_End"
    when Key_Home : return o << "Key_Home"
    when Key_Left : return o << "Key_Left"
    when Key_Up : return o << "Key_Up"
    when Key_Right : return o << "Key_Right"
    when Key_Down : return o << "Key_Down"
    when Key_Insert : return o << "Key_Insert"
    when Key_Delete : return o << "Key_Delete"
    when Key_Escape : return o << "Key_Escape"
    when Key_F1 : return o << "Key_F1"
    when Key_F2 : return o << "Key_F2"
    when Key_F3 : return o << "Key_F3"
    when Key_F4 : return o << "Key_F4"
    when Key_F5 : return o << "Key_F5"
    when Key_F6 : return o << "Key_F6"
    when Key_F7 : return o << "Key_F7"
    when Key_F8 : return o << "Key_F8"
    when Key_F9 : return o << "Key_F9"
    when Key_F10 : return o << "Key_F10"
    when Key_F11 : return o << "Key_F11"
    when Key_F12 : return o << "Key_F12"
    when Key_Space : return o << "Key_Space"
    when Key_A : return o << "Key_A"
    when Key_B : return o << "Key_B"
    when Key_C : return o << "Key_C"
    when Key_D : return o << "Key_D"
    when Key_E : return o << "Key_E"
    when Key_F : return o << "Key_F"
    when Key_G : return o << "Key_G"
    when Key_H : return o << "Key_H"
    when Key_I : return o << "Key_I"
    when Key_J : return o << "Key_J"
    when Key_K : return o << "Key_K"
    when Key_L : return o << "Key_"
    when Key_M : return o << "Key_M"
    when Key_N : return o << "Key_N"
    when Key_O : return o << "Key_O"
    when Key_P : return o << "Key_P"
    when Key_Q : return o << "Key_Q"
    when Key_R : return o << "Key_R"
    when Key_S : return o << "Key_S"
    when Key_T : return o << "Key_T"
    when Key_U : return o << "Key_U"
    when Key_V : return o << "Key_V"
    when Key_W : return o << "Key_W"
    when Key_X : return o << "Key_X"
    when Key_Y : return o << "Key_Y"
    when Key_Z : return o << "Key_Z"
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
      describe_wkey_event(e)
    elsif e.kind_of?(Wt::WMouseEvent)
      decribe_wmouse_event(e)
    end
  end

  def describe_wkey_event(e)
    ss = "Key: " << e.key.to_s << "<br/>" <<
         "Modifiers: " << modifiersToString(e.modifiers) << "<br/>" <<
         "Char code: " << e.charCode << "<br/>" <<
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

  def decribe_wmouse_event(e)
    ss = "Ext::Button: " << e.button.to_s << "<br/>" <<
         "Modifiers: " << modifiersToString(e.modifiers) << "<br/>" <<
         "Document coordinates: " << mouseEventCoordinatesToString(e.document) << "<br/>" <<
         "Window coordinates: " << mouseEventCoordinatesToString(e.window) << "<br/>" <<
         "Screen coordinates: " << mouseEventCoordinatesToString(e.screen) << "<br/>" <<
         "Ext::Widget coordinates: " << mouseEventCoordinatesToString(e.widget) << "<br/>" <<
         "DragDelta coordinates: " << mouseEventCoordinatesToString(e.dragDelta) << "<br/>"
    @mouseEventDescription.text = ss
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
