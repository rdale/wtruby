require 'wt'

class MapperApplication < Wt::WApplication
  def initialize(env)
    super(env)
    setTitle("WSignalMapper test")

    button1 = Wt::WPushButton.new("Button 1", root) do |b| 
      b.setMargin(Wt::WLength.new(5), Wt::Left) 
    end

    button2 = Wt::WPushButton.new("Button 2", root) do |b| 
      b.setMargin(Wt::WLength.new(5), Wt::Left) 
    end

    button3 = Wt::WPushButton.new("Button 3", root) do |b| 
      b.setMargin(Wt::WLength.new(5), Wt::Left) 
    end

    myMap = Wt::WSignalMapper.new(self)

    myMap.mapped.connect(SLOT(self, :onClick))
    myMap.mapConnect(button1.clicked, button1)
    myMap.mapConnect(button2.clicked, button2)
    myMap.mapConnect(button3.clicked, button3)

    root.addWidget(Wt::WBreak.new)
    @result = Wt::WText.new(root)
  end

  def onClick(source)
    @result.text = "Clicked on " + source.text
  end
end

Wt::WRun(ARGV) do |env|
  MapperApplication.new(env)
end

