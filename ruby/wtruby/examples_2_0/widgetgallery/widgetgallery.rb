#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class WidgetGallery < Wt::WApplication

  def initialize(env)
    super(env)
    setTitle("Wt widgets demo")
    # load text bundles (for the tr function)
    messageResourceBundle.use("text")
    messageResourceBundle.use("charts")
    messageResourceBundle.use("treeview")

    @contentsStack = Wt::WStackedWidget.new
    # Show scrollbars when needed ...
    @contentsStack.overflow = Wt::WContainerWidget::OverflowAuto
    # ... and work around a bug in IE (see setOverflow documentation)
    @contentsStack.positionScheme = Wt::Relative
    @contentsStack.styleClass = "contents"

    @eventDisplayer = EventDisplayer.new(nil)

    #
    # Setup the menu (and submenus)
    #
    @menu = Wt::WMenu.new(@contentsStack, Wt::Vertical, nil)
    @menu.renderAsList = true
    @menu.styleClass = "menu"
    @menu.setInternalPathEnabled
    @menu.internalBasePath = "/"

    initialInternalPath = internalPath

    addToMenu(@menu, "Basics", BasicControls.new(@eventDisplayer))
    addToMenu(@menu, "Form Widgets", FormWidgets.new(@eventDisplayer))
    addToMenu(@menu, "Form Validators", Validators.new(@eventDisplayer))
    addToMenu(@menu, "Ext Widgets", ExtWidgets.new(@eventDisplayer))
    addToMenu(@menu, "Vector Graphics", GraphicsWidgets.new(@eventDisplayer))
    addToMenu(@menu, "Dialogs", DialogWidgets.new(@eventDisplayer))
    addToMenu(@menu, "Charts", ChartWidgets.new(@eventDisplayer))
    addToMenu(@menu, "MVC Widgets", MvcWidgets.new(@eventDisplayer))
    addToMenu(@menu, "Events", EventsDemo.new(@eventDisplayer))
    addToMenu(@menu, "Style and Layout", StyleLayout.new(@eventDisplayer))

    setInternalPath(initialInternalPath)
    @menu.select(0)

    #
    # Add it all inside a layout
    #
    @horizLayout = Wt::WHBoxLayout.new(root)
    @vertLayout = Wt::WVBoxLayout.new

    @horizLayout.addWidget(@menu, 0)
    @horizLayout.addLayout(@vertLayout, 1)
    @vertLayout.addWidget(@contentsStack, 1)
    @vertLayout.addWidget(@eventDisplayer)
    #
    # Set our style sheet last, so that it loaded after the ext stylesheets.
    #
    useStyleSheet("everywidget.css")
    useStyleSheet("dragdrop.css")
  end

  def addToMenu(menu, name, controls)
    if controls.hasSubMenu
      smi = Wt::WSubMenuItem.new(name, controls)
      subMenu = Wt::WMenu.new(@contentsStack, Wt::Vertical, nil)
      subMenu.renderAsList = true
      subMenu.styleClass = "menu submenu"
      subMenu.setInternalPathEnabled
      subMenu.internalBasePath = "/" + smi.pathComponent
      smi.subMenu = subMenu
      controls.populateSubMenu(subMenu)
      subMenu.select(-1)
      menu.addItem(smi)
    else
      menu.addItem(name, controls)
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
