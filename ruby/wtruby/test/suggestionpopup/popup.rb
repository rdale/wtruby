require 'wt'

class ContactSuggestions < Wt::WSuggestionPopup

  @@contactOptions = Options.new do |opt|
    opt.highlightBeginTag = "<b>"
    opt.highlightEndTag = "</b>"
    opt.listSeparator = ?,
    opt.whitespace = ' \n'
    opt.wordSeparators = '-., "@\n;'
    opt.appendReplacedText = ", "
  end

  def initialize(parent = nil)
    super(s1 = generateMatcherJS(@@contactOptions),
          s2 = generateReplacerJS(@@contactOptions),
          parent )
    puts s1
    puts s2
  end

end


class PopupApplication < Wt::WApplication
  def initialize(env)
    super(env)
    setTitle("WSuggestionPopup test")
    container = Wt::WContainerWidget.new

    popup = ContactSuggestions.new(container)
    textEdit = Wt::WTextArea.new(container)
	textEdit.text = "Here is some text"
    popup.forEdit(textEdit)
    popup.addSuggestion("foo", "A foo suggestion")
    popup.addSuggestion("bar", "A bar tip")
    # popup.styleClass("suggest")

    root.addWidget(container)
   end
end

Wt::WRun(ARGV) do |env|
  PopupApplication.new(env)
end

