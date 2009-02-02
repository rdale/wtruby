#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
#  composerexample
#
# A suggestion popup suggesting contacts from an addressbook.
#
# This popup provides suggestions from a list of contact, by
# matching parts of the name or email adress with the current
# value being edited. It also supports editing a list of email
# addresses.
#
# The popup is only available when JavaScript is available, and
# is implemented entirely on the client-side.
#
class ContactSuggestions < Wt::WSuggestionPopup

  @@contactOptions = Options.new do |opt|
    opt.highlightBeginTag = "<b>"
    opt.highlightEndTag = "</b>"
    opt.listSeparator = ?,.ord
    opt.whitespace = ' \n'
    opt.wordSeparators = '-., "@\n;'
    opt.appendReplacedText = ", "
  end

  def initialize(parent)
    super(  generateMatcherJS(@@contactOptions),
            generateReplacerJS(@@contactOptions),
            parent )
  end

  def addressBook=(contacts)
    clearSuggestions

    for i in 0...contacts.size
      addSuggestion(contacts[i].formatted, contacts[i].formatted)
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
