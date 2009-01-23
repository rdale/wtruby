#!/usr/bin/ruby
# dragexample Drag and Drop example
require 'character.rb'


# Create an image which can be dragged.
#
# The image to be displayed when dragging is given by smallurl, and
# configured with the given mime type
#
def createDragImage(url, smallurl, mimeType, p)
  result = Wt::WImage.new(url, p)
  dragImage = Wt::WImage.new(smallurl, p)

  #
  # Set the image to be draggable, showing the other image (dragImage)
  # to be used as the widget that is visually dragged.
  #
  result.setDraggable(mimeType, dragImage, true)

  return result
end

class DragExample < Wt::WContainerWidget
  def initialize(root)
    super(root)
    Wt::WText.new("<p>Help these people with their decision by dragging one of " \
        "the pills.</p>", self)

    if !$wApp.environment.javaScript
      Wt::WText.new("<i>This examples requires that javascript support is " \
          "enabled.</i>", self)
    end

    pills = Wt::WContainerWidget.new(self)
    pills.contentAlignment = Wt::WWidget::AlignCenter

    createDragImage("icons/blue-pill.jpg",
        "icons/blue-pill-small.png",
        "blue-pill", pills)
    createDragImage("icons/red-pill.jpg",
        "icons/red-pill-small.png",
        "red-pill", pills)

    dropSites = Wt::WContainerWidget.new(self)

    Character.new("Neo", dropSites)
    Character.new("Morpheus", dropSites)
    Character.new("Trinity", dropSites)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
