#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

class TreeListExample < Wt::WContainerWidget

  def initialize(parent)
    super(parent)
    @testCount = 0
    @tree = makeTreeMap("TreeListExample", 0)
    addWidget(@tree)
    @tree.expand

    treelist = makeTreeMap("Tree List", @tree)
    wstateicon = makeTreeMap("class IconPair", treelist)
    makeTreeFile("IconPair.h", wstateicon)
    makeTreeFile("IconPair.C", wstateicon)
    wtreenode = makeTreeMap("class TreeNode", treelist)
    makeTreeFile("TreeNode.h", wtreenode)
    makeTreeFile("TreeNode.C", wtreenode)
    wtreeexample = makeTreeMap("class TreeListExample", treelist)
    makeTreeFile("TreeListExample.h", wtreeexample)
    makeTreeFile("TreeListExample.C", wtreeexample)

    @testMap = makeTreeMap("Test map", @tree)

    #
    # Buttons to demonstrate dynamically changing the tree contents
    # implies no magic at all.
    #
    addWidget(Wt::WText.new(  "<p>Use the following buttons to change the " \
                              "contents of the Test map:</p>" ) )

    addBox = Wt::WGroupBox.new("Add map", self)

    mapNameLabel = Wt::WLabel.new("Map name:", addBox)
    mapNameLabel.setMargin(Wt::WLength.new(1, Wt::WLength::FontEx), Wt::Right)
    @mapNameEdit = Wt::WLineEdit.new("Map", addBox)
    mapNameLabel.buddy = @mapNameEdit

    #
    # Example of validation: make the map name mandatory, and give
    # feedback when invalid.
    #
    @mapNameEdit.validator = Wt::WValidator.new(true)

    @addMapButton = Wt::WPushButton.new("Add map", addBox)
    @addMapButton.clicked.connect(SLOT(self, :addMap))

    Wt::WBreak.new(self)

    removeBox = Wt::WGroupBox.new("Remove map", self)

    @removeMapButton = Wt::WPushButton.new("Remove map", removeBox)
    @removeMapButton.clicked.connect(SLOT(self, :removeMap))
    @removeMapButton.disable
  end

  def addMap
    if @mapNameEdit.validate == Wt::WValidator::Valid
      node = makeTreeMap(@mapNameEdit.text + " " + @testCount += 1.to_s, @testMap)
      makeTreeFile("File " + @testCount.to_s, node)
      @removeMapButton.enable
    else
      @mapNameEdit.styleClass = "Wt-invalid"
    end
  end

  def removeMap
    numMaps = @testMap.childNodes.size

    if numMaps > 0
      c = rand(numMaps)

      child = @testMap.childNodes[c]
      @testMap.removeChildNode(child)
      # delete child

      if numMaps == 1
        @removeMapButton.disable
      end
    end
  end

  def makeTreeMap(name, parent)
    labelIcon = IconPair.new("icons/yellow-folder-closed.png",
                    "icons/yellow-folder-open.png",
                    false)

    node = TreeNode.new(name, Wt::WText::PlainFormatting, labelIcon, 0)
    if parent
      parent.addChildNode(node)
    end

    return node
  end

  def makeTreeFile(name, parent)
    labelIcon = IconPair.new("icons/document.png", "icons/yellow-folder-open.png",
                    false)

    node = TreeNode.new("<a href=\"" + wApp.fixRelativeUrl("wt/src/" + name.toUTF8) +
                                  "\" target=\"_blank\">" +
                                  name + "</a>", Wt::WText::XHTMLFormatting,
                                  labelIcon, 0)
    if parent
      parent.addChildNode(node)

      return node
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
