#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'iconpair.rb'
require 'treenode.rb'

#
#  treelist Treelist example
#
# A demonstration of the treelist.
#
# This is the main class for the treelist example.
#
class DemoTreeList < Wt::WContainerWidget

  def initialize(parent)
    super(parent)
    @testCount = 0
    addWidget(  Wt::WText.new(  "<h2>Wt Tree List example</h2>" \
                                "<p>This is a simple demo of a treelist, implemented using" \
                                " <a href='http:#witty.sourceforge.net/'>Wt</a>.</p>" \
                                "<p>The leaves of the tree contain the source code of the " \
                                "tree-list in the classes <b>TreeNode</b> and " \
                                "<b>IconPair</b>, as well as the implementation of this " \
                                "demo itself in the class <b>DemoTreeList</b>.</p>" ) )

    @tree = makeTreeMap("Examples", nil)
    addWidget(@tree)
  
    treelist = makeTreeMap("Tree List", @tree)
    wstateicon = makeTreeMap("class IconPair", treelist)
    makeTreeFile("<a href=\"iconpair.rb\">iconpair.rb</a>", wstateicon)
    wtreenode = makeTreeMap("class TreeNode", treelist)
    makeTreeFile("<a href=\"treenode.rb\">treenode.rb</a>", wtreenode)
    demotreelist = makeTreeMap("class DemoTreeList", treelist)
    makeTreeFile("<a href=\"demotreelist.rb\">demotreelist.rb</a>", demotreelist)

    @testMap = makeTreeMap("Test map", @tree)

    #
    # Buttons to dynamically demonstrate changing the tree contents.
    #
    addWidget(  Wt::WText.new(  "<p>Use the following buttons to change the tree " \
                                "contents:</p>" ) )
  
    @addMapButton = Wt::WPushButton.new("Add map", self)
    @addMapButton.clicked.connect(SLOT(self, :addMap))
  
    @removeMapButton = Wt::WPushButton.new("Remove map", self)
    @removeMapButton.clicked.connect(SLOT(self, :removeMap))
    @removeMapButton.disable
  
    addWidget(Wt::WText.new("<p>Remarks:" \
         "<ul>" \
         "<li><p>This is not the instantiation of a pre-defined " \
         "tree list component, but the full implementation of such " \
         "a component, in about 350 lines of Ruby code !</p> " \
         "<p>In comparison, the <a href='http:#myfaces.apache.org'> " \
         "Apache MyFaces</a> JSF implementation of tree2, with similar " \
         "functionality, uses about 2400 lines of Java, and 140 lines " \
         "of JavaScript code.</p></li>" \
         "<li><p>Once loaded, the tree list does not require any " \
         "interaction with the server for handling the click events on " \
         "the <img src='icons/nav-plus-line-middle.gif' /> and " \
         "<img src='icons/nav-minus-line-middle.gif' /> icons, " \
         "because these events have been connected to slots using " \
         "STATIC connections. Such connections are converted to the " \
         "appropriate JavaScript code that is inserted into the page. " \
         "Still, the events are signaled to the server to update the " \
         "application state.</p></li>" \
         "<li><p>In contrast, the buttons for manipulating the tree " \
         "contents use DYNAMIC connections, and thus the update " \
         "is computed at server-side, and communicated back to the " \
         "browser (by default using AJAX).</p></li>" \
         "<li><p>When loading a page, only visible widgets (that are not " \
         "<b>setHidden(true)</b>) are transmitted. " \
         "The remaining widgets are loaded in the background after " \
         "rendering the page. " \
         "As a result the application is loaded as fast as possible.</p>" \
         "</li>" \
         "<li><p>The browser reload button is supported and behaves as " \
         "expected: the page is reloaded from the server. Again, " \
         "only visible widgets are transmitted immediately.</p> " \
         "<p>(For the curious, this is the way to see the actual " \
         "HTML/JavaScript code !)</p></li>" \
         "</ul></p>"))
  end

  def addMap
    node = makeTreeMap("Map " + (@testCount += 1).to_s, @testMap)
    makeTreeFile("File " + @testCount.to_s, node)
    @removeMapButton.enable
  end

  def removeMap
    numMaps = @testMap.childNodes.size
  
    if numMaps > 0
      c = rand % numMaps
  
      child = @testMap.childNodes[c]
      @testMap.removeChildNode(child)
  
      if numMaps == 1
        @removeMapButton.disable
      end
    end
  end

  def makeTreeMap(name, parent)
    labelIcon = IconPair.new( "icons/yellow-folder-closed.png",
                              "icons/yellow-folder-open.png",
                              false)
  
    node = TreeNode.new(name, Wt::PlainFormatting, labelIcon, nil)
    if parent
      parent.addChildNode(node)
    end
  
    return node
  end

  def makeTreeFile(name, parent)
    labelIcon = IconPair.new("icons/document.png", "icons/yellow-folder-open.png", false)
  
    node = TreeNode.new(name, Wt::XHTMLFormatting, labelIcon, nil)
    if parent
      parent.addChildNode(node)
    end
  
    return node
  end
end

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  @demo = DemoTreeList.new(app.root)

  #
  # The look & feel of the tree node is configured using a CSS style sheet.
  # If you are not familiar with CSS, you can use the Wt::WCssDecorationStyle
  # class ...
  #
  treeNodeLabelStyle = Wt::WCssDecorationStyle.new
  treeNodeLabelStyle.font.setFamily(Wt::WFont::Serif, "Helvetica")
  app.styleSheet.addRule(".treenodelabel", treeNodeLabelStyle)

  #
  # ... or if you speak CSS fluently, you can add verbatim rules.
  #
  app.styleSheet.addRule( ".treenodechildcount",
                          "color:blue; font-family:Helvetica,serif;" )

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
