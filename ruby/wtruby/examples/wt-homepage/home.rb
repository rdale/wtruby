#!/usr/bin/ruby
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

require 'wt'
require 'treelistexample.rb'

class Home < Wt::WApplication
  Lang = Struct.new(    "Lang", 
                        :code, 
                        :path, 
                        :shortDescription, 
                        :longDescription )
  @@languages = [ Lang.new("en", "/", "en", "English"), 
                  Lang.new("cn", "/cn/", "汉语", "中文 (Chinese)") ]

  #
  # A utility container widget which defers creation of its single
  # child widget until the container is loaded (which is done on-demand
  # by a Wt::WMenu). The constructor takes the create function for the
  # widget as a parameter.
  #
  # We use this to defer widget creation until needed, which is used
  # for the Treelist example tab.
  #
  class DeferredWidget < Wt::WContainerWidget
    def initialize(method, target)
      super()
      @method = method
      @target = target
    end

    def load
      addWidget(@target.send(@method))
    end
  end

  def deferCreate(method, target)
    return DeferredWidget.new(method, target)
  end

  # Shortcut for a <div id=""> */
  class Div < Wt::WContainerWidget
    def initialize(parent, id)
      super(parent)
      setId(id)
    end
  end

  def initialize(env)
    super(env)
    @recentNews = nil
    @historicalNews = nil
    @releases = nil
    messageResourceBundle.use("wt-home", false)
    useStyleSheet("images/wt.css")
    useStyleSheet("images/wt_ie.css", "lt IE 7")
    useStyleSheet("home.css")
    setTitle("Wt, C ++ 1 Web Toolkit")

    setLocale("")
    @language = nil

    topWrapper = Div.new(root, "top_wrapper")
    topContent = Div.new(topWrapper, "top_content")

    languagesDiv = Div.new(topContent, "top_languages")

    lmap = Wt::WSignalMapper.new(self)
    lmap.mapped.connect(SLOT(self, :changeLanguage))

    for i in 0...@@languages.size
      if i != 0
        Wt::WText.new("- ", languagesDiv)
      end
      l = @@languages[i]

      a = Wt::WAnchor.new(bookmarkUrl(l.path), l.longDescription, languagesDiv)
      lmap.mapConnect(a.clicked, i)
    end

    topWt = Wt::WText.new(tr("top_wt"), topContent)
    topWt.inline = false
    topWt.id = "top_wt"

    bannerWt = Wt::WText.new(tr("banner_wrapper"), root)
    bannerWt.id = "banner_wrapper"

    mainWrapper = Div.new(root, "main_wrapper")
    mainContent = Div.new(mainWrapper, "main_content")
    mainMenu = Div.new(mainContent, "main_menu")

    contents = Wt::WStackedWidget.new
    contents.id = "main_page"

    @mainMenu = Wt::WMenu.new(contents, Wt::Vertical, mainMenu)
    @mainMenu.renderAsList = true

    # Use "/" instead of "/introduction/" as internal path
    @mainMenu.addItem(tr("introduction"), introduction).setPathComponent("")
    @mainMenu.addItem(tr("news"), deferCreate(:news, self), Wt::WMenuItem::PreLoading)
    @mainMenu.addItem(tr("features"), wrapViewOrDefer(:features), Wt::WMenuItem::PreLoading)
    @mainMenu.addItem(tr("documentation"), wrapViewOrDefer(:documentation), Wt::WMenuItem::PreLoading)
    @mainMenu.addItem(tr("examples"), examples, Wt::WMenuItem::PreLoading)
    @mainMenu.addItem(tr("download"), deferCreate(:download, self), Wt::WMenuItem::PreLoading)
    @mainMenu.addItem(tr("community"), wrapViewOrDefer(:community), Wt::WMenuItem::PreLoading)

    @mainMenu.itemSelectRendered.connect(SLOT(self, :updateTitle))
    @mainMenu.itemSelected.connect(SLOT(self, :logInternalPath))
    @mainMenu.select(0)

    # Make the menu be internal-path aware.
    @mainMenu.setInternalPathEnabled
    @mainMenu.internalBasePath = "/"

    @sideBarContent = Wt::WContainerWidget.new(mainMenu)

    mainContent.addWidget(contents)
    clearAll = Wt::WContainerWidget.new(mainContent)
    clearAll.styleClass = "clearall"

    footerWrapper = Wt::WText.new(tr("footer_wrapper"), root)
    footerWrapper.id = "footer_wrapper"

    internalPathChanged.connect(SLOT(self, :setLanguageFromPath))
  end

  def changeLanguage(index)
    if index == @language
      return
    end

    prevLanguage = @language

    setLanguage(index)

    langPath = @@languages[index].path
    if internalPath.empty?
      setInternalPath(langPath)
    else
      prevLangPath = @@languages[prevLanguage].path
      path = internalPath.substr(prevLangPath.length)
      setInternalPath(langPath + path)
    end
  end

  def setLanguage(index)
    l = @@languages[index]

    setLocale(l.code)

    langPath = l.path
    @mainMenu.internalBasePath = langPath
    @examplesMenu.internalBasePath = langPath + "examples"
    updateTitle

    @language = index
  end

  def setLanguageFromPath(prefix)
    if prefix == "/"
      langPath = internalPathNextPart(prefix)

      if langPath.empty?
        langPath = '/'
      else
        langPath = '/' + langPath + '/'
      end

      newLanguage = 0

      for i in 0...@@languages.size
        if @@languages[i].path == langPath
          newLanguage = i
          break
        end
      end

      if newLanguage != @language
        setLanguage(newLanguage)
      end
    end
  end

  def updateTitle
    setTitle(tr("wt") + " - " + @mainMenu.currentItem.text)
  end

  def logInternalPath
    # simulate an access log for the interal paths
    log("path") << internalPath
  end

  def introduction
    return Wt::WText.new(tr("home.intro"))
  end

  def refresh
    if @recentNews
      readNews(@recentNews, "latest-news.txt")
    end

    if @historicalNews
      readNews(@historicalNews, "historical-news.txt")
    end

    if @releases
      readReleases(@releases, "releases.txt")
    end

    # super
  end

  def news
    result = Wt::WContainerWidget.new
    result.addWidget(Wt::WText.new(tr("home.news")))

    result.addWidget(Wt::WText.new(tr("home.latest-news")))
    @recentNews = Wt::WTable.new
    readNews(@recentNews, "latest-news.txt")
    result.addWidget(@recentNews)

    result.addWidget(Wt::WText.new(tr("home.historical-news")))
    @historicalNews = Wt::WTable.new
    readNews(@historicalNews, "historical-news.txt")
    result.addWidget(@historicalNews)

    return result
  end

  def status
    return Wt::WText.new(tr("home.status"))
  end

  def features
    return Wt::WText.new(tr("home.features"))
  end

  def documentation
    return Wt::WText.new(tr("home.documentation"))
  end

  def helloWorldExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.hello"), result)

    tree = makeTreeMap("Hello world", nil)
    makeTreeFile("hello.rb", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def homepageExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.wt"), result)

    tree = makeTreeMap("Wt Homepage", nil)
    home = makeTreeMap("class Home", tree)
    makeTreeFile("home.rb", home)
    treeexample = makeTreeMap("class TreeListExample", tree)
    makeTreeFile("treelistexample.rb", treeexample)
    makeTreeFile("wt-home.xml", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def chartExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.chart"), result)

    tree = makeTreeMap("Chart example", nil)
    chartsExample = makeTreeMap("class ChartsExample", tree)
    makeTreeFile("chartsexample.rb", chartsExample)
    chartConfig = makeTreeMap("class ChartConfig", tree)
    makeTreeFile("chartconfig.rb", chartConfig)
    panelList = makeTreeMap("class PanelList", tree)
    makeTreeFile("panellist.rb", panelList)
    makeTreeFile("csvutil.rb", tree)
    makeTreeFile("charts.xml", tree)
    makeTreeFile("charts.css", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def treelistExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.treelist"), result)
    TreeListExample.new(result)
    Wt::WText.new(tr("home.examples.treelist-remarks"), result)

    return result
  end

  def hangmanExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.hangman"), result)

    tree = makeTreeMap("Hangman game", nil)
    tree.loadPolicy = Wt::WTreeNode::PreLoading

    widgets = makeTreeMap("Widgets", tree)
    loginwidget = makeTreeMap("class LoginWidget", widgets)
    makeTreeFile("loginWidget.rb", loginwidget)
    hangmanwidget = makeTreeMap("class HangmanWidget", widgets)
    makeTreeFile("hangmanwidget.rb", hangmanwidget)
    highscoreswidget = makeTreeMap("class HighScoresWidget", widgets)
    makeTreeFile("highscoreswidget.rb", highscoreswidget)
    hangmangame = makeTreeMap("class HangmanGame", widgets)
    makeTreeFile("hangmangame.rb", hangmangame)
    other = makeTreeMap("Other", tree)
    hangmandb = makeTreeMap("class HangmanDb", other)
    makeTreeFile("hangmandb.rb", hangmandb)
    dictionary = makeTreeMap("class Dictionary", other)
    makeTreeFile("dictionary.rb", dictionary)
    makeTreeFile("hangman.rb", other)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def composerExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.composer"), result)

    tree = makeTreeMap("Mail composer example", nil)

    classMap = makeTreeMap("class AddresseeEdit", tree)
    makeTreeFile("addresseeedit.rb", classMap)
    classMap = makeTreeMap("class AttachmentEdit", tree)
    makeTreeFile("attachmentedit.rb", classMap)
    classMap = makeTreeMap("class ComposeExample", tree)
    makeTreeFile("composeexample.rb", classMap)
    classMap = makeTreeMap("class Composer", tree)
    makeTreeFile("composer.rb", classMap)
    classMap = makeTreeMap("class ContactSuggestions", tree)
    makeTreeFile("contactsuggestions.rb", classMap)
    classMap = makeTreeMap("class Label", tree)
    makeTreeFile("label.rb", classMap)
    classMap = makeTreeMap("class Option", tree)
    makeTreeFile("option.rb", classMap)
    classMap = makeTreeMap("class OptionList", tree)
    makeTreeFile("optionlist.rb", classMap)
    makeTreeFile("contact.rb", tree)
    makeTreeFile("attachment.rb", tree)
    makeTreeFile("composer.xml", tree)
    makeTreeFile("composer.css", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def dragdropExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.dragdrop"), result)

    tree = makeTreeMap("DragDrop example", nil)

    classMap = makeTreeMap("class Character", tree)
    makeTreeFile("character.rb", classMap)
    makeTreeFile("dragexample.rb", tree)
    makeTreeFile("dragdrop.css", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def chatExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.chat"), result)

    tree = makeTreeMap("Chat example", nil)

    classMap = makeTreeMap("class SimpleChatWidget", tree)
    makeTreeFile("simplechatwidget.rb", classMap)
    classMap = makeTreeMap("class SimpleChatServer", tree)
    makeTreeFile("simplechatserver.rb", classMap)
    makeTreeFile("simplechat.rb", tree)
    makeTreeFile("simplechat.css", tree)
    makeTreeFile("simplechat.xml", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def fileExplorerExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.fileexplorer"), result)

    tree = makeTreeMap("File explorer example", nil)

    classMap = makeTreeMap("class FileTreeTableNode", tree)
    makeTreeFile("filetreetablewode.rb", classMap)
    classMap = makeTreeMap("class FileTreeTable", tree)
    makeTreeFile("filetreetable.rb", classMap)
    makeTreeFile("filetreeexample.rb", tree)
    makeTreeFile("filetree.css", tree)

    tree.expand

    result.addWidget(tree)

    return result
  end

  def calendarExample
    result = Wt::WContainerWidget.new

    Wt::WText.new(tr("home.examples.calendar"), result)
    
    Wt::WText.new(tr("home.examples.calendar.datepicker"), result)

    tab = Wt::WTable.new(result)
    Wt::WText.new(tr("home.examples.calendar.enter-birth-date"),
              tab.elementAt(0, 0))
    dateEdit = Wt::WLineEdit.new(tab.elementAt(0, 1))
    dateEdit.setMargin(Wt::WLength.new(5), Wt::Right)

    Wt::WDatePicker.new(new Wt::WPushButton.new("..."), dateEdit,
                    false, tab.elementAt(0, 1))
    tab.elementAt(0, 0).margin = Wt::WLength.new(8)
    tab.elementAt(0, 1).margin = Wt::WLength.new(8)

    Wt::WText.new(tr("home.examples.calendar.plain"), result)
    cal = Wt::WCalendar.new(false, result)
    cal.margin = Wt::WLength.new(8)

    Wt::WText.new(tr("home.examples.calendar.multi"), result)
    cal = Wt::WCalendar.new(false, result)
    cal.multipleSelection = true
    cal.margin = Wt::WLength.new(8)

    return result
  end

  def wrapViewOrDefer(createWidget)
    #
    # We can only create a view if we have javascript for the client-side
    # tree manipulation -- otherwise we require server-side event handling
    # which is not possible with a view since the server-side widgets do
    # not exist. Otherwise, all we can do to avoid unnecessary server-side
    # resources is deferring creation until load time.
    #
    if !environment.agentIEMobile && environment.javaScript
      return Wt.makeStaticModel(createWidget, self)
    else
      return deferCreate(createWidget, self)
    end
  end

  def examples
    result = Wt::WContainerWidget.new

    result.addWidget(Wt::WText.new(tr("home.examples")))

    @examplesMenu = Wt::WTabWidget.new(result)

    #
    # The following code is functionally equivalent to:
    #
    #   @examplesMenu.addTab(helloWorldExample, "Hello world")
    #
    # However, we optimize here for memory consumption (it is a homepage
    # after all, and we hope to be slashdotted some day)
    #
    # Therefore, we wrap all the static content (including the tree
    # widgets), into WViewWidgets with static models. In self way the
    # widgets are not actually stored in memory on the server.
    #
    # For the tree list example (for which we cannot use a view with a
    # static model, since we allow the tree to be manipulated) we use
    # the defer utility function to defer its creation until it is
    # loaded.
    #

    # Use "/examples" instead of "/examples/hello_world" as internal path
    @examplesMenu.addTab(wrapViewOrDefer(:helloWorldExample), tr("hello-world")).setPathComponent("")

    @examplesMenu.addTab(wrapViewOrDefer(:chartExample), tr("charts"))
    @examplesMenu.addTab(wrapViewOrDefer(:homepageExample), tr("wt-homepage"))
    @examplesMenu.addTab(deferCreate(:treelistExample, self), tr("treelist"))
    @examplesMenu.addTab(wrapViewOrDefer(:hangmanExample), tr("hangman"))
    @examplesMenu.addTab(wrapViewOrDefer(:chatExample), tr("chat"))
    @examplesMenu.addTab(wrapViewOrDefer(:composerExample), tr("mail-composer"))
    @examplesMenu.addTab(wrapViewOrDefer(:dragdropExample), tr("drag-and-drop"))
    @examplesMenu.addTab(wrapViewOrDefer(:fileExplorerExample), tr("file-explorer"))
    @examplesMenu.addTab(deferCreate(:calendarExample, self), tr("calendar"))

    @examplesMenu.currentChanged.connect(SLOT(self, :logInternalPath))

    # Enable internal paths for the example menu
    @examplesMenu.setInternalPathEnabled
    @examplesMenu.internalBasePath = "/examples"

    return result
  end

  def download
    result = Wt::WContainerWidget.new
    result.addWidget(Wt::WText.new(tr("home.download")))
    result.addWidget(Wt::WText.new(tr("home.download.license")))
    result.addWidget(Wt::WText.new(tr("home.download.requirements")))
    result.addWidget(Wt::WText.new(tr("home.download.cvs")))
    result.addWidget(Wt::WText.new(tr("home.download.packages")))

    @releases = Wt::WTable.new
    readReleases(@releases, "releases.txt")
    result.addWidget(@releases)

    result.addWidget(Wt::WText.new( "<p>Older releases are still available at " +
                                    href( "http:#sourceforge.net/project/showfiles.php?" \
                                          "group_id=153710#files",
                                          "sourceforge.net") +
                                    "</p>"))

    return result
  end

  def href(url, description)
    return "<a href=\"" + url + "\" target=\"_blank\">" + description + "</a>"
  end

  def community
    return Wt::WText.new(tr("home.community"))
  end

  def readNews(newsTable, newsfile)
    f = File.open(newsfile)
    newsTable.clear
    row = 0

    while line = f.gets do
      line = f.gets
      fields = line.split(',')
      newsTable.elementAt(row, 0).addWidget(Wt::WText.new("<p><b>" + fields[0] + "</b></p>"))
      newsTable.elementAt(row, 0).contentAlignment = Wt::AlignCenter | Wt::AlignTop
      newsTable.elementAt(row, 0).resize(Wt::WLength.new(16, Wt::WLength::FontEx), Wt::WLength.new)
      newsTable.elementAt(row, 1).addWidget(Wt::WText.new("<p>" + fields[1] + "</p>"))

      row += 1
    end
  end

  def readReleases(releaseTable, releasefile)
    f = File.open(releasefile)

    releaseTable.clear

    releaseTable.elementAt(0, 0).addWidget(Wt::WText.new(tr("home.download.version")))
    releaseTable.elementAt(0, 1).addWidget(Wt::WText.new(tr("home.download.date")))
    releaseTable.elementAt(0, 2).addWidget(Wt::WText.new(tr("home.download.description")))

    releaseTable.elementAt(0, 0).resize(Wt::WLength.new(10, Wt::WLength::FontEx),
                                          Wt::WLength.new)
    releaseTable.elementAt(0, 1).resize(Wt::WLength.new(15, Wt::WLength::FontEx),
                                          Wt::WLength.new)

    row = 1

    while line = f.gets
      fields = line.split(',')
      version = fields[0]
      releaseTable.elementAt(row, 0).addWidget(Wt::WText.new( href( "http:#prdownloads.sourceforge.net/witty/wt-" +
                                                                      version + ".tar.gz?download", "Wt " + version ) ) )
      releaseTable.elementAt(row, 1).addWidget(Wt::WText.new(fields[1]))
      releaseTable.elementAt(row, 2).addWidget(Wt::WText.new(fields[2]))

      row += 1
    end
  end

  def makeTreeMap(name, parent)
    labelIcon = Wt::WIconPair.new("icons/yellow-folder-closed.png",
                      "icons/yellow-folder-open.png", false)
    node = Wt::WTreeNode.new(name, labelIcon, parent)
    node.label.formatting = Wt::PlainFormatting

    if !parent
      node.imagePack = "icons/"
      node.expand
      node.loadPolicy = Wt::WTreeNode::NextLevelLoading
    end

    return node
  end

  def makeTreeFile(name, parent)
    labelIcon = Wt::WIconPair.new(  "icons/document.png",
                                    "icons/yellow-folder-open.png", false )

    return Wt::WTreeNode.new( "<a href=\"" + fixRelativeUrl("wt/src/" + name) +
                              "\" target=\"_blank\">" +
                              name + "</a>", labelIcon, parent)
  end
end

Wt::WRun(ARGV) do |env|
  begin
    # support for old (< Wt-2.2) homepage URLS: redirect from "states"
    # to "internal paths"
    # this contains the initial "history state" in old Wt versions
    puts "arguments: #{env.arguments}"
    historyKey = env.getArgument("historyKey")[0]

    mainStr = { "main:0" => "/",
                "main:1" => "/news",
                "main:2" => "/features",
                "main:4" => "/examples",
                "main:3" => "/documentation",
                "main:5" => "/download",
                "main:6" => "/community" }

    exampleStr = {  "example:0" => "/examples",
                    "example:1" => "/examples/charts",
                    "example:2" => "/examples/wt-homepage",
                    "example:3" => "/examples/treelist",
                    "example:4" => "/examples/hangman",
                    "example:5" => "/examples/chat",
                    "example:6" => "/examples/mail-composer",
                    "example:7" => "/examples/drag-and-drop",
                    "example:8" => "/examples/file-explorer",
                    "example:9" => "/examples/calendar" }

    if historyKey.include?("main:4")
      exampleStr.each_pair do |key, value|
        if historyKey.include?(key)
          app = Wt::WApplication.new(env)
          app.log("notice") << "redirecting old style URL '" <<
                             historyKey << "' to internal path: '" <<
                             value << "'"
          app.redirect(app.bookmarkUrl(value))
          app.quit
          return app
        end
      end
    else
      mainStr.each_pair do |key, value|
        if historyKey.include?(key)
          app = Wt::WApplication.new(env)

          app.log("notice") << "redirecting old style URL '" <<
                             historyKey << "' to internal path: '" <<
                             value << "'"
          app.redirect(app.bookmarkUrl(value))
          app.quit
          return app
        end
      end
    end
    # unknown history key, just continue
  rescue
    # no "historyKey argument, simply continue
  end

  Home.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
