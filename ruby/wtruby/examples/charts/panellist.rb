#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

class PanelList < Wt::WContainerWidget

  def initialize(parent)
    super(parent)
  end

  def addWidget(text, w)
    p = Wt::WPanel.new
    p.title = text
    p.centralWidget = w
  
    addPanel(p)
  
    return p
  end

  def addPanel(panel)
    panel.collapsible = true
    panel.collapse
  
    panel.expandedSS.connect(SLOT(self, :onExpand))

    # Invoke the super method for addWidget() in Wt::WContainerWidget
    method_missing(:addWidget, panel)
  end

  def onExpand(notUndo)
    panel = sender
  
    if notUndo
      @wasExpanded = -1
  
      for i in 0...children.size
        p = children[i]
        if p != panel
          if !p.isCollapsed
            @wasExpanded = i
          end
          p.collapse
        end
      end
    else
      if @wasExpanded != -1
        p = children[@wasExpanded]
        p.expand
      end
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
