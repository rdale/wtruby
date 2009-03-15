#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale


#
# fileexplorer File Explorer example
#
#@{*/
#! \brief A tree table that displays a file tree.
#
# The table allows one to browse a path, and all its subdirectories,
# using a tree table. In addition to the file name, it shows file size
# and modification date.
#
# The table use FileTreeTableNode objects to display the actual content
# of the table. 
#
# The tree table uses the LazyLoading strategy of WTreeNode to dynamically
# load contents for the tree.
#
# This widget is part of the Wt File Explorer example.
#
class FileTreeTable < Wt::WTreeTable
  #
  # Create a new FileTreeTable to browse the given path.
  #
  def initialize(path, parent = nil)
    super(parent)
    addColumn("Size", Wt::WLength.new(80))
    addColumn("Modified", Wt::WLength.new(110))
  
    header(1).styleClass = "fsize"
    header(2).styleClass = "date"
  
    setTreeRoot(FileTreeTableNode.new(path), "File")
  
    treeRoot.imagePack = "icons/"
    treeRoot.expand
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
