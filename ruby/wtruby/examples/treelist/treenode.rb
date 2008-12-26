#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#
#  treelist
#
# Example implementation of a single tree list node.
#
# <i>This is an example of a basic treelist implementation. As of
# version 1.1.8, a more flexible treenode implementation is included as
# part of the library: WTreeNode.</i>
#
# A tree list is constructed by nesting TreeNode objects in a tree
# hierarchy.
#
# A TreeNode has a label, and optionally a two-state label icon, which
# defines a different image depending on the state of the node (expanded
# or collapsed). When the node has any children, a child count is also
# indicated.
#
# Next to the icons, two style classes determine the look of a TreeNode:
# the label has style "treenodelabel", and the child count has as style
# "treenodechildcount".
#
# Use CSS nested selectors to apply different styles to different treenodes.
# For example, to style the treenode with style class "mynode":
#
# The behaviour of the tree node is to collapse all children when the
# node is expanded (self is similar to how most tree node implementations
# work).
#
# The widget uses a number of images which must be available in an
# "icons/" folder (see the %Wt treelist examples).
#
# This widget is part of the Wt treelist example.
#
class TreeNode < Wt::WCompositeWidget
  attr_accessor :parentNode, :childNodes

  Middle = 0
  Last = 1

 # Construct a tree node with the given label.
  #
  # The label is formatted in a WText with the given formatting.
  # The labelIcon (if not 0) will appear next to the label and its state
  # will reflect the expand/collapse state of the node.
  #
  # Optionally, a userContent widget may be associated with the node.
  # When expanded, self widget will be shown below the widget, but above
  # any of the children nodes.
  #
  def initialize(labelText, labelFormatting, labelIcon, parent)
    super(parent)
    @parentNode = nil
    @childNodes = []
    @labelIcon = labelIcon
    # pre-learned stateless implementations ...
    implementStateless(:expand, :undoExpand)
    implementStateless(:collapse, :undoCollapse)

    @imageLine = ["icons/line-middle.gif", "icons/line-last.gif"]
    @imagePlus = ["icons/nav-plus-line-middle.gif", "icons/nav-plus-line-last.gif"]
    @imageMin = ["icons/nav-minus-line-middle.gif", "icons/nav-minus-line-last.gif"]

    # ... or auto-learned stateless implementations
    # which do not need undo functions
    #implementStateless(:expand)
    #implementStateless(:collapse)
  
    setImplementation(@layout = Wt::WTable.new)
  
    @expandIcon = IconPair.new(@imagePlus[Last], @imageMin[Last])
    @expandIcon.hide
    @noExpandIcon = Wt::WImage.new(@imageLine[Last])
  
    @expandedContent = Wt::WContainerWidget.new
    @expandedContent.hide
  
    @labelText = Wt::WText.new(labelText)
    @labelText.formatting = labelFormatting
    @labelText.styleClass = "treenodelabel"
    @childCountLabel = Wt::WText.new
    @childCountLabel.setMargin(Wt::WLength.new(7), Wt::Left)
    @childCountLabel.styleClass = "treenodechildcount"
  
    @layout.elementAt(0, 0).addWidget(@expandIcon)
    @layout.elementAt(0, 0).addWidget(@noExpandIcon)
  
    if @labelIcon
      @layout.elementAt(0, 1).addWidget(@labelIcon)
      @labelIcon.verticalAlignment = Wt::AlignMiddle
    end
    @layout.elementAt(0, 1).addWidget(@labelText)
    @layout.elementAt(0, 1).addWidget(@childCountLabel)
  
    @layout.elementAt(1, 1).addWidget(@expandedContent)
  
    @layout.elementAt(0, 0).contentAlignment = Wt::AlignTop
    @layout.elementAt(0, 1).contentAlignment = Wt::AlignMiddle
  
    @expandIcon.icon1Clicked.connect(SLOT(self, :expand))
    @expandIcon.icon2Clicked.connect(SLOT(self, :collapse))
  end

  def lastChildNode?
    if @parentNode
      return @parentNode.childNodes.last == self
    else
      return true
    end
  end

  def addChildNode(node)
    @childNodes << node
    node.parentNode = self
    @expandedContent.addWidget(node)
    childNodesChanged
  end

  def removeChildNode(node)
    @childNodes.delete(node)
    node.parentNode = nil
    @expandedContent.removeWidget(node)
    childNodesChanged
  end

  def childNodesChanged
    for i in 0...@childNodes.size
      @childNodes[i].adjustExpandIcon
    end
  
    adjustExpandIcon
  
    if @childNodes.size > 0
      @childCountLabel.setText("(" + @childNodes.size.to_s + ")")
    else
      @childCountLabel.text = ""
    end
  
    resetLearnedSlots
  end

  def collapse
    @wasCollapsed = @expandedContent.isHidden
  
    @expandIcon.state = 0
    @expandedContent.hide
    if @labelIcon
      @labelIcon.state = 0
    end
  end

  def expand
    @wasCollapsed = @expandedContent.isHidden
  
    @expandIcon.state = 1
    @expandedContent.show
    if @labelIcon
      @labelIcon.state = 1
    end
  
    #
    # collapse all children
    #
    for i in 0...@childNodes.size
      @childNodes[i].collapse
    end
  end

  def undoCollapse
    if !@wasCollapsed
      # re-expand
      @expandIcon.state = 1
      @expandedContent.show
      if @labelIcon
        @labelIcon.state = 1
      end
    end
  end

  def undoExpand
    if @wasCollapsed
      # re-collapse
      @expandIcon.state = 0
      @expandedContent.hide
      if @labelIcon
        @labelIcon.state = 0
      end
    end

    #
    # undo collapse of children
    #
    for i in 0...@childNodes.size
      @childNodes[i].undoCollapse
    end
  end

  def adjustExpandIcon
    index = lastChildNode? ? Last : Middle
  
    if @expandIcon.icon1.imageRef != @imagePlus[index]
      @expandIcon.icon1.imageRef = @imagePlus[index]
    end
    if @expandIcon.icon2.imageRef != @imageMin[index]
      @expandIcon.icon2.imageRef = @imageMin[index]
    end
    if @noExpandIcon.imageRef != @imageLine[index]
      @noExpandIcon.imageRef = @imageLine[index]
    end
  
    if index == Last
      @layout.elementAt(0, 0).decorationStyle.backgroundImage = ""
      @layout.elementAt(1, 0).decorationStyle.backgroundImage = ""
    else
      @layout.elementAt(0, 0).decorationStyle.setBackgroundImage( "icons/line-trunk.gif",
                                                                  Wt::WCssDecorationStyle::RepeatY)
      @layout.elementAt(1, 0).decorationStyle.setBackgroundImage( "icons/line-trunk.gif",
                                                                  Wt::WCssDecorationStyle::RepeatY)
    end

    if @childNodes.empty?
      if @noExpandIcon.isHidden
        @noExpandIcon.show
        @expandIcon.hide
      end
    elsif @expandIcon.isHidden
        @noExpandIcon.hide
        @expandIcon.show
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
