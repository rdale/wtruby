#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#  gitmodelexample
#
# %Git utility class for browsing git archives.
#
# Far from complete! Only browses git revisions.
#
class Git
  Tree = 0
  Commit = 1
  Blob = 2

  class Object
    attr_accessor :id, :type, :name

    def initialize(id, type)
      @id = id
      @type = type
    end
  end

  #
  # Class for compactly storing a 20-byte SHA1 digest.
  #
  class ObjectId < String
    def initialize(id)
      if id.length != 40
        raise "Git: not a valid SHA1 id: #{id}"
      end

      @id = id
      @value = (@id.scan(/../).collect {|v| v.hex }).pack("C*")
      super(@id)
    end

    def value
      @value
    end
  end

  # Run a command and capture its stdout into a string.
  # Uses and maintains a cache.
  #
  class POpenWrapper
    attr_reader :contents, :finished, :exitStatus

    def initialize(s, cache)
      cached = false

      cache.each_index do |i|
        if cache[i][0] == s
          @contents = cache[i][1]
          @exitStatus = 0
          cached = true
          first_entry = cache[0]
          cache[0] = cache[i]
          cache[i] = first_entry
        end
      end

      if !cached
        stream = IO.popen(s, "r")
        @contents = stream.readlines.collect {|line| line.lstrip.rstrip}
        stream.close
        if $?.exitstatus != 0
          raise "Git: could not execute: '" + s + "'"
        end

        @exitStatus = $?.exitstatus
        cache.pop
        cache.push [s, @contents]

        @idx = 0
      end
    end

    def finished
      true
    end
  end

#
# About the git files:
# type="commit":
#  - of a reference, like the SHA1 ID obtained from git-rev-parse of a
#    particular revision
#  - contains the SHA1 ID of the tree
#
# type="tree":
#  100644 blob 0732f5e4def48d6d5b556fbad005adc994af1e0b    CMakeLists.txt
#  040000 tree 037d59672d37e116f6e0013a067a7ce1f8760b7c    Wt
#  <mode> SP <@type> SP <object> TAB <file>
#
# type="blob": contents of a file
#

  def initialize
    @cache = Array.new(3, [nil, nil])
  end

  def setRepositoryPath(repositoryPath)
    @repository = repositoryPath
    checkRepository
  end

  def repositoryPath=(path)
    setRepositoryPath(path)
  end

  def getCommitTree(revision)
    commit = getCommit(revision)
    return getTreeFromCommit(commit)
  end

  def catFile(id)
    result = []
    if !getCmdResult("cat-file -p " + id, result, -1)
      raise "Git: could not cat '" + @id + "'"
    end

    return result
  end

  def getCommit(revision)
    sha1Commit = []
    getCmdResult("rev-parse " + revision, sha1Commit, 0)
    return ObjectId.new(sha1Commit[0])
  end

  def getTreeFromCommit(commit)
    treeLine = []
    if !getCmdResultForTag("cat-file -p " + commit, treeLine, "tree")
      raise "Git: could not parse tree from commit '" + commit + "'"
    end

    v = treeLine[0].split(' ')
    if v.length != 2
      raise "Git: could not parse tree from commit '" + commit + "': '" + treeLine + "'"
    end

    return ObjectId.new(v[1])
  end

  def treeGetObject(tree, index)
    objectLine = []
    if ! getCmdResult("cat-file -p " + tree, objectLine, index)
      raise "Git: could not read object %" + index.to_s + "  from tree " + tree
    end

    v1 = objectLine[0].split("\t")
    if v1.length != 2
      raise "Git: could not parse tree object line: '" + objectLine[0] + "'"
    end

    v2 = v1[0].split(' ')
    if v2.length != 3
      raise "Git: could not parse tree object line: '" + objectLine[0] + "'"
    end

    stype = v2[1]
    type = nil
    if stype == "tree"
      type = Tree
    elsif stype == "blob"
      type = Blob
    else
      raise "Git: Unknown type: " + stype
    end

    result = Git::Object.new(ObjectId.new(v2[2]), type)
    result.name = v1[1]

    return result
  end

  def treeSize(tree)
    return getCmdResultLineCount("cat-file -p " + tree)
  end

  def getCmdResult(gitCmd, result, index)
    p = POpenWrapper.new("git --git-dir=" + @repository + " " + gitCmd, @cache)

    if p.exitStatus != 0
      raise "Git error: " + p.contents[0]
    end

    if index == -1
      result.concat(p.contents)
      return true
    else
      result.push(p.contents[index])
    end

    return true
  end

  def getCmdResultForTag(gitCmd, result, tag)
    p = POpenWrapper.new("git --git-dir=" + @repository + " " + gitCmd, @cache)

    if p.exitStatus != 0
      raise "Git error: " + p.contents[0]
    end

    p.contents.each do |line|
      if line.include?(tag)
        result.push(line)
        return true
      end
    end

    return false
  end

  def getCmdResultLineCount(gitCmd)
    p = POpenWrapper.new("git --git-dir=" + @repository + " " + gitCmd, @cache)

    if p.exitStatus != 0
      raise "Git error: " + p.contents[0]
    end

    return p.contents.length
  end

  def checkRepository
    p = POpenWrapper.new("git --git-dir=" + @repository + " branch", @cache)

    if p.exitStatus != 0
      raise "Git error: " + p.contents[0]
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
