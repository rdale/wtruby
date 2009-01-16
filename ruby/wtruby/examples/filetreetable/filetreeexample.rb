#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale

require 'wt'
require 'filetreetable.rb'
require 'filetreetablenode.rb'

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.title = "File explorer example"
  app.useStyleSheet("filetree.css")

  treeTable = FileTreeTable.new("/home/rdale/kde/src/4/kdebindings/ruby/wtruby")
#  treeTable = FileTreeTable.new("/tmp")
  treeTable.resize(Wt::WLength.new(500), Wt::WLength.new(600))
  treeTable.tree.selectionMode = Wt::ExtendedSelection
  treeTable.treeRoot.nodeVisible = false
  treeTable.treeRoot.childCountPolicy = Wt::WTreeNode::Enabled

  app.root.addWidget(treeTable)

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
