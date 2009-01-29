#!/usr/bin/ruby
#
# Copyright (C) 2006 Wim Dumon, Koen Deforche
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'git.rb'
require 'gitmodel.rb'

#! \class SourceView
#  \brief View class for source code.
#
# A view class is used so that no server-side memory is used while displaying
# a potentially large file.
#
class SourceView < Wt::WViewWidget
  # Constructor.
  #
  # The <i>role</i> will be used to retrieve data from a model index to
  # be displayed.
  #
  def initialize(role)
    super()
    @role = role
    @index = Wt::WModelIndex.new
  end

  # Set model index.
  #
  # The view is rerendered if the index contains data.new.
  #
  def setIndex(index)
    if index != @index && (!index.valid? || !index.data(@role).empty?)
      @index = index
      update
    end
  end

  def index=(index)
    setIndex(index)
  end

  # Return the widget that renders the view.
  #
  # Returns he view contents: renders the file to a Wt::WText widget.
  # Wt::WViewWidget deletes self widget after every rendering step.
  #
  def renderView
    result = Wt::WText.new
    result.inline = false

    if !@index.valid?
      return result
    end

    d = @index.data(@role)
    t = d.to_s

    result.textFormat = Wt::PlainText
    result.text = t

    return result
  end
end

#! \class GitViewApplication
#  \brief A simple application to navigate a git repository.
#
# This examples demonstrates how to use the custom model use GitModel
# with a WTreeView.
#
class GitViewApplication < Wt::WApplication
  def initialize(env) 
    super(env)
    useStyleSheet("gitview.css")
    setTitle("Git model example")

    gitRepo = ENV["GITVIEW_REPOSITORY_PATH"]

    grid = Wt::WGridLayout.new
    grid.addWidget(Wt::WText.new("Git repository path:"), 0, 0)
    grid.addWidget(@repositoryEdit = Wt::WLineEdit.new(gitRepo ? gitRepo : ""), 0, 1, Wt::AlignLeft)
    grid.addWidget(@repositoryError = Wt::WText.new, 0, 2)
    grid.addWidget(Wt::WText.new("Revision:"), 1, 0)
    grid.addWidget(@revisionEdit = Wt::WLineEdit.new("master"), 1, 1, Wt::AlignLeft)
    grid.addWidget(@revisionError = Wt::WText.new, 1, 2)

    @repositoryEdit.textSize = 30
    @revisionEdit.textSize = 20
    @repositoryError.styleClass = "error-msg"
    @revisionError.styleClass = "error-msg"

    @repositoryEdit.enterPressed.connect(SLOT(self, :loadGitModel))
    @revisionEdit.enterPressed.connect(SLOT(self, :loadGitModel))

    b = Wt::WPushButton.new("Load")
    b.clicked.connect(SLOT(self, :loadGitModel))
    grid.addWidget(b, 2, 0, Wt::AlignLeft)

    @gitView = Wt::WTreeView.new
    @gitView.resize(Wt::WLength.new(300), Wt::WLength.new)
    @gitView.sortingEnabled = false
    @gitModel = GitModel.new(self)
    @gitView.model = @gitModel
    @gitView.selectionMode = Wt::SingleSelection
    @gitView.selectionChanged.connect(SLOT(self, :showFile))

    @sourceView = SourceView.new(GitModel::ContentsRole)
    @sourceView.styleClass = "source-view"

    if environment.javaScript
      #
      # We have JavaScript: We can use layout managers so everything will
      # always fit nicely in the window.
      #
      if !environment.agentWebKit
        @sourceView.resize(Wt::WLength.new(100, Wt::WLength::Percentage), Wt::WLength.new)
      end

      topLayout = Wt::WVBoxLayout.new
      topLayout.addLayout(grid, 0, Wt::AlignTop | Wt::AlignLeft)

      gitLayout = Wt::WHBoxLayout.new
      gitLayout.setLayoutHint("table-layout", "fixed")
      gitLayout.addWidget(@gitView, 0)
      gitLayout.addWidget(@sourceView, 1)
      topLayout.addLayout(gitLayout, 1)

      root.layout = topLayout
      root.styleClass = "maindiv"
    else
      #
      # Wt::No JavaScript: let's make the best of the situation using regular
      # CSS-based layout
      #
      root.styleClass = "maindiv"
      top = Wt::WContainerWidget.new
      top.setLayout(grid, Wt::AlignTop | Wt::AlignLeft)
      root.addWidget(top)
      root.addWidget(@gitView)
      @gitView.floatSide = Wt::Left
      @gitView.margin = Wt::WLength.new(6)
      root.addWidget(@sourceView)
      @sourceView.margin = Wt::WLength.new(6)
    end
  end

  # Change repository and/or revision
  #
  def loadGitModel
    @sourceView.index = Wt::WModelIndex.new
    @repositoryError.text = ""
    @revisionError.text = ""
    begin
      @gitModel.repositoryPath = @repositoryEdit.text
      begin
        @gitModel.loadRevision(@revisionEdit.text)
      rescue RuntimeError => e
        @revisionError.text = e.to_s
      end
    rescue RuntimeError => e
      @repositoryError.text = e.to_s
    end
  end

  # Displayed the currently selected file.
  #
  def showFile
    if @gitView.selectedIndexes.empty?
      return
    end

    selected = Wt::WModelIndex.new(@gitView.selectedIndexes[0])
    @sourceView.index = selected
  end
end

Wt::WRun(ARGV) do |env|
  GitViewApplication.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
