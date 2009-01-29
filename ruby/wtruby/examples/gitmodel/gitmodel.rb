#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#  gitmodelexample
#
#! \class GitModel
#  \brief A model that retrieves revision trees from a git repository.
#
# In its present form, it presents only a single column of data: the
# file names. Additional data could be easily added. Git "tree" objects
# correspond to folders, and "blob" objects to files.
#
# The model is read-only, does not support sorting (that could be
# provided by using a WSortFilterProxyModel).
#
# The model loads only minimal information in memory: to create model indexes
# for folders. These cannot be uniquely identified by their SHA1 id, since
# two identical folders at different locations would have the same SHA1 id.
#
# The internal id of model indexes created by the model uniquely identify
# a containing folder for a particular file.
#
class GitModel < Wt::WAbstractItemModel
  ContentsRole = Wt::UserRole

  class ChildIndex
    attr_reader :parentId, :index

    def initialize(aParent, anIndex)
      @parentId = aParent
      @index = anIndex
    end

    def <(other)
      if @parentId < other.parentId
        return true
      elsif @parentId > other.parentId
        return false
      else 
        return @index < other.index
      end
    end
  end

  # Used to uniquely locate a folder within the folder hierarchy.
  class Tree
    def initialize(parentId, index, object)
      @index = ChildIndex.new(parentId, index)
      @treeObject = object
    end

    def parentId
      return @index.parentId
    end

    def index
      return @index.index
    end

    # Returns the SHA1 id for the git tree object.
    def treeObject
      return @treeObject
    end
  end

  def initialize(parent)
    super(parent)
    @git = Git.new
    @treeData = []
    @childPointer = {}
  end

  def setRepositoryPath(gitRepositoryPath)
    @git.repositoryPath = gitRepositoryPath
    loadRevision("master")
  end

  def repositoryPath=(path)
    setRepositoryPath(path)
  end

  def loadRevision(revName)
    treeRoot = @git.getCommitTree(revName)

    # You need to call this method before invalidating all existing
    # model indexes. Anyone listening for this event could temporarily
    # convert some model indexes to a raw index pointer, but this model
    # does not reimplement these methods.
    layoutAboutToBeChanged.emit

    @treeData.clear
    @childPointer.clear

    # Store the tree root as @treeData[0]
    @treeData.push(Tree.new(-1, -1, treeRoot))

    layoutChanged.emit
  end

  def parent(index)
    # @treeData[0] indicates the top-level parent.
    if !index.valid? || index.internalId.nil?
      return Wt::WModelIndex.new
    else
      # get the item that corresponds to the parent ...
      item = @treeData[index.internalId]

      # ... and construct that identifies the parent:
      #   row = child index in the grand parent
      #   internalId = id of the grand parent
      return createIndex(item.index, 0, item.parentId)
    end
  end

  def index(row, column, parent)
    # the top-level parent has id=0.
    if !parent.valid?
      @parentId = 0
    else
      # the internal id of the parent identifies the grand parent
      grandParentId = parent.internalId

      # lookup the parent id for the parent himself, based on grand parent
      # and child-@index (=row) within the grand parent
      @parentId = getTreeId(grandParentId, parent.row)
    end

    return createIndex(row, column, @parentId)
  end

  def getTreeId(parentId, childIndex)
    index = ChildIndex.new(parentId, childIndex)

    if @childPointer[index].nil?
      # no tree object was already allocated, so do that now.

      # lookup the git SHA1 object Id (within the parent)
      parentItem = @treeData[@parentId]
      o = @git.treeGetObject(parentItem.treeObject, childIndex)

      # and add to @treeData and @childPointer data structures
      @treeData.push(Tree.new(@parentId, childIndex, o.id))
      result = @treeData.size - 1
      @childPointer[index] = result
      return result
    else
      return i[1]
    end
  end

  def columnCount(index)
    # currently only one column
    return 1
  end

  def rowCount(index)
    # we are looking for the git SHA1 id of a tree object (since only folders
    # may contain children).
    objectId = nil

    if index.valid?
      # only column 0 items may contain children
      if index.column != 0
        return 0
      end

      o = getObject(index)
      if o.type == Git::Tree
        objectId = o.id
      else
        # not a folder: no children
        return 0
      end
    else
      # the index corresponds to the root object
      if @treeData.empty?
        # model not yet loaded !
        return 0
      else
        objectId = @treeData[0].treeObject
      end
    end

    return @git.treeSize(objectId)
  end

  def data(index, role = Wt::DisplayRole)
    if !index.valid?
      return Boost::Any.new
    end
    # Only 3 data roles on column 0 data are supported:
    # - DisplayRole: the file name
    # - DecorationRole: an icon (folder or file)
    # - ContentsRole: the file contents
    #
    if index.column == 0
      object = getObject(index)
      if role == DisplayRole
        if object.type == Git::Tree
          return Boost::Any.new(object.name + '/')
        else
          return Boost::Any.new(object.name)
        end
      elsif role == DecorationRole
        if object.type == Git::Blob
          return Boost::Any.new("icons/git-blob.png")
        elsif object.type == Git::Tree
          return Boost::Any.new("icons/git-tree.png")
        end
      elsif role == ContentsRole
        if object.type == Git::Blob
          return Boost::Any.new(@git.catFile(object.id))
        end
      end
    end

    return Boost::Any.new
  end

  def headerData(section, orientation, role)
    if orientation == Wt::Horizontal && role == Wt::DisplayRole
      return Boost::Any.new("File")
    else
      return Boost::Any.new
    end
  end

  def getObject(index)
    @parentId = index.internalId
    parentItem = @treeData[@parentId]
    return @git.treeGetObject(parentItem.treeObject, index.row)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
