#!/usr/bin/ruby
# dragexample Drag and Drop example
require 'wt'
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

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.title = "Drag &amp; drop"
  Wt::WText.new("<h1>Wt Drag &amp; drop example.</h1>", app.root)

  Wt::WText.new("<p>Help these people with their decision by dragging one of " \
      "the pills.</p>", app.root)

  if !env.javaScript
    Wt::WText.new("<i>This examples requires that javascript support is " \
        "enabled.</i>", app.root)
    end

  pills = Wt::WContainerWidget.new(app.root)
  pills.contentAlignment = Wt::WWidget::AlignCenter

  createDragImage("icons/blue-pill.jpg",
      "icons/blue-pill-small.png",
      "blue-pill", pills)
  createDragImage("icons/red-pill.jpg",
      "icons/red-pill-small.png",
      "red-pill", pills)

  dropSites = Wt::WContainerWidget.new(app.root)

  Character.new("Neo", dropSites)
  Character.new("Morpheus", dropSites)
  Character.new("Trinity", dropSites)

  app.useStyleSheet("dragdrop.css")

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
