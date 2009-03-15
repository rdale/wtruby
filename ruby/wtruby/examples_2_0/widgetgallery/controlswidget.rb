#
# Copyright (C) 2008 Emweb bvba
#
# See the LICENSE file for terms of use.
#
class ControlsWidget < Wt::WContainerWidget
  # Inserts the classname in the parent, with a link to the
  # documentation
  attr_reader :hasSubMenu

  def initialize(ed, hasSubMenu)
    super() 
    @ed = ed
    @hasSubMenu = hasSubMenu   
  end

  def deferCreate(method, target)
    return DeferredWidget.new(method, target)
  end

  def populateSubMenu(menu)
  end

  def escape(name)
    name.gsub(':', '_1')
  end

  def doxygenAnchor(classname)
    ss = '<a href="http://www.webtoolkit.eu/wt/doc/reference/html/class' +
      escape("Wt::" + classname) +
      '.html" target="_blank">doc</a>'

    return ss
  end

  def title(classname)
    return '<span class="title">' + classname + "</span> " +
      '<span class="doc">[' +
      doxygenAnchor(classname) + "]</span>"
  end

  def topic(classname, *args)
    if args.length == 1
      Wt::WText.new(title(classname) + "<br/>", args[0])
    elsif args.length == 2
      Wt::WText.new(title(classname) + " and " + title(args[0]) + "<br/>", args[1])
    elsif args.length == 3
      Wt::WText.new(title(classname) + ", " + title(args[0]) + " and " +
                    title(args[1]) + "<br/>", args[2])
    elsif args.length == 4
      Wt::WText.new(title(classname) + ", " + title(args[0]) + ", " +
                  title(args[1]) + " and " + title(args[2]) + "<br/>",
                  args[3])
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
