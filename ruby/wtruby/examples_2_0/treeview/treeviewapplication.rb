#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

require 'wt'
require 'treeviewexample'

class TreeViewApplication < Wt::WApplication

  def initialize(env)
    super(env)
    TreeViewExample.new(true, root)
    #
    # Stub for the drink info
    #
    @aboutDrink = Wt::WText.new("", root)
    
    internalPathChanged.connect(SLOT(self, :handlePathChange))
  end

  def handlePathChange(prefix)
    if prefix == "/drinks/"
      drink = internalPathNextPart(prefix)
      
      @aboutDrink.text = tr("drink-" + drink)
    end
  end

end

Wt::WRun(ARGV) do |env|
  app = TreeViewApplication.new(env)
  app.title = "WTreeView example"
  app.messageResourceBundle.use("drinks")
  app.styleSheet.addRule("button", "margin: 2px")
  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
