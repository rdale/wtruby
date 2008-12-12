#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Converted to Ruby by Richard Dale


#*
# @addtogroup fileexplorer
#
#@{*/
#! \brief A single node in a file tree table.
#
# The node manages the details about one file, and if the file is a
# directory, populates a subtree with nodes for every directory item.
#
# The tree node reimplements Wt::WTreeTableNode::populate() to populate
# a directory node only when the node is expanded. In self way, only
# directories that are actually browsed are loaded from disk.
#
class FileTreeTableNode < Wt::WTreeTableNode
  # Construct a new node for the given file.
  #
  # The path.
  # Reimplements WTreeNode::populate to read files within a directory.
  # Reimplements WTreeNode::expandable
  # Create the iconpair for representing the path.
  def initialize(path)
    super(File.basename(path), createIcon(path))
    @path = path
    label.formatting = Wt::PlainFormatting

    if File.exist?(path)
      if !File.directory?(path)
        fsize = File.size(path)
        setColumnWidget(1, Wt::WText.new(false, fsize.to_s))
        columnWidget(1).styleClass = "fsize"
      else
        setSelectable(false)
      end

      t = File.stat(path).mtime
      c = t.strftime("%b %d %Y")
      setColumnWidget(2, Wt::WText.new(c))
      columnWidget(2).styleClass = "date"
    end
  end

  def createIcon(path)
    if File.exists?(path) && File.directory?(path)
      return Wt::WIconPair.new( "icons/yellow-folder-closed.png",
                                "icons/yellow-folder-open.png", false )
    else
      return Wt::WIconPair.new( "icons/document.png",
                                "icons/yellow-folder-open.png", false )
    end
  end

  def populate
    if File.directory?(@path)
      Dir.glob(@path + "/*").each do |p|
        addChildNode(FileTreeTableNode.new(p))
      end
    end
  end

  def expandable
    if !populated
      return File.directory?(@path)
    else
      return super
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
