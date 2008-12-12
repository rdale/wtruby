require 'wt'
require 'wtext'

class SplitterApplication < Wt::WApplication
  def initialize(env)
    super(env)
    setTitle("Splitter test")
    container = Wt::WContainerWidget.new

    Wt::Internal::setDebug Wt::WtDebugChannel::WTDB_VIRTUAL

    # Horizontal Splitter
    horizontalSplitter = Wt::Ext::Splitter.new(container)
    horizontalSplitter.resize(Wt::WLength.new(400), Wt::WLength.new(100))
  
    horizontalSplitter.addWidget(Wt::WText.new("Left"))
p horizontalSplitter.children
    horizontalSplitter.children.last.resize(Wt::WLength.new(150), Wt::WLength.new)
    horizontalSplitter.children.last.setMinimumSize(Wt::WLength.new(130), Wt::WLength.new)
    horizontalSplitter.children.last.setMaximumSize(Wt::WLength.new(170), Wt::WLength.new)

    horizontalSplitter.addWidget(Wt::WText.new("Center"))
p horizontalSplitter.children
    horizontalSplitter.children.last.resize(Wt::WLength.new(100), Wt::WLength.new)
    horizontalSplitter.children.last.setMinimumSize(Wt::WLength.new(50), Wt::WLength.new)
  
    horizontalSplitter.addWidget(Wt::WText.new("Right"))
p horizontalSplitter.children
    horizontalSplitter.children.last.resize(Wt::WLength.new(50), Wt::WLength.new)
    horizontalSplitter.children.last.setMinimumSize(Wt::WLength.new(50), Wt::WLength.new)
p horizontalSplitter.styleClass

=begin
    # Vertical Splitter
    verticalSplitter = Wt::Ext::Splitter.new(Wt::Vertical, container)
    verticalSplitter.resize(Wt::WLength.new(100), Wt::WLength.new(200))
  
    verticalSplitter.addWidget(Wt::WText.new("Top"))
p verticalSplitter.children
    verticalSplitter.children.last.resize(Wt::WLength.new, Wt::WLength.new(100))
    verticalSplitter.children.last.setMinimumSize(Wt::WLength.new, Wt::WLength.new(50))
    verticalSplitter.children.last.setMaximumSize(Wt::WLength.new, Wt::WLength.new(196))
  
    verticalSplitter.addWidget(Wt::WText.new("Center"))
p verticalSplitter.children
    verticalSplitter.children.last.resize(Wt::WLength.new, Wt::WLength.new(100))
=end
    root.addWidget(container)
   end
end

Wt::WRun(ARGV) do |env|
  SplitterApplication.new(env)
end

