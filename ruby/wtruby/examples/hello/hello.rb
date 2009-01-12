#!/usr/bin/ruby
=begin
 Copyright (C) 2006 Wim Dumon, Koen Deforche

 See the LICENSE file for terms of use.

 Translated to Ruby by Richard Dale
=end

require 'wt'

#
# A simple hello world application class which demonstrates how to react
# to events, read input, and give feed-back.
#
class HelloApplication < Wt::WApplication

  #
  # The env argument contains information about the new session, and
  # the initial request. It must be passed to the WApplication
  # constructor so it is typically also an argument for your custom
  # application constructor.
  #
  def initialize(env)
    super(env)
    setTitle("Hello world")                                # application title

    root.addWidget(Wt::WText.new("Your name, please ? "))  # show some text
    @nameEdit = Wt::WLineEdit.new(root) do |e|             # allow text input
      e.setFocus                                           # give focus
    end

    button = Wt::WPushButton.new("Greet me.", root) do |b| # create a button
      b.setMargin(Wt::WLength.new(5), Wt::Left)            # add 5 pixels margin 
    end

    root.addWidget(Wt::WBreak.new)                         # insert a line break
    @greeting = Wt::WText.new(root)                        # empty text

    # Connect signals with slots
    button.clicked.connect(SLOT(self, :greet))
    @nameEdit.enterPressed.connect(SLOT(self, :greet))
  end

  def greet
    # Update the text, using text input into the @nameEdit field.
    @greeting.text = "Hello there, " + @nameEdit.text
  end
end

=begin
 Your main method may set up some shared resources, but should then
 start the server application (FastCGI or httpd) that starts listening
 for requests, and handles all of the application life cycles.

 The block passed to WRun specifies the code that will instantiate
 new application objects. That block is executed when a new user surfs
 to the Wt application, and after the library has negotiated browser
 support. The block should return a newly instantiated application
 object.
=end
Wt::WRun(ARGV) do |env|
  # You could read information from the environment to decide whether
  # the user has permission to start a new application
  HelloApplication.new(env)
end

