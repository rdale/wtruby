#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

#  composerexample
#
# A clickable option
#
# This widget is part of the Wt composer example.
#
# On its own, an option is a text which is style "option".
# An Option may also be used as items in an OptionList.
#
class Option < Wt::WContainerWidget

  def initialize(text, parent = nil)
    super(parent)
    @sep = nil
    @list = nil
    setInline(true)
  
    @option = Wt::WText.new(text, self)
    @option.styleClass = "option"
  end

  def item
    return @option
  end

  def text=(text)
    @option.text = text
  end

  def optionList=(l)
    @list = l
  end

  def addSeparator
    @sep = Wt::WText.new("|", self)
    @sep.styleClass = "sep"
  end

  def hideSeparator
    @sep.hide
  end

  def showSeparator
    @sep.show
  end

  def hidden=(hidden)
    super(hidden)

    if @list
      @list.optionVisibilityChanged(self, hidden)
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
