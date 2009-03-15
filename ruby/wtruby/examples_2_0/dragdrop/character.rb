#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale



# dragexample
#
# A Matrix character that takes red and/or blue pills.
#
# The Character class demonstrates how to accept and react to drop
# events.
#
class Character < Wt::WText 

  # Create a new character with the given name.
  def initialize(name, parent)
    super(parent)
    @name = name
    @redDrops = 0
    @blueDrops = 0
    setText(@name + " got no pills")

    setStyleClass("character")

    #
    # Accept drops, and indicate self with a change in CSS style class.
    #
    acceptDrops("red-pill", "red-drop-site")
    acceptDrops("blue-pill", "blue-drop-site")
  
    setInline(false)
  end

  # React to a drop event.
  def dropEvent(event)
    if event.mimeType == "red-pill"
      @redDrops += 1
    end
    if event.mimeType == "blue-pill"
      @blueDrops += 1
    end
  
    text = @name + " got "
  
    if @redDrops != 0
      text += @redDrops.to_s + " red pill"
    end
    if @redDrops > 1
      text += "s"
    end
  
    if @redDrops != 0 && @blueDrops != 0
      text += " and "
    end
  
    if @blueDrops != 0
      text += @blueDrops.to_s + " blue pill"
    end
    if @blueDrops > 1
      text += "s"
    end
  
    setText(text)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
