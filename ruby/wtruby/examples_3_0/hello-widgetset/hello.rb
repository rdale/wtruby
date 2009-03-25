#!/usr/bin/env ruby
=begin
 Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.

 See the LICENSE file for terms of use.

 Translated to Ruby by Richard Dale
=end

require 'wt'

class HelloApplication < Wt::WApplication
  def initialize(env, embedded)
    super(env)

    #
    # By default, "dynamic script tags" are used to relay event information
    # in WidgetSet mode. This has the benefit of allowing an application to
    # be embedded from within a web page on another domain.
    #
    # You can revert to plain AJAX requests using the following call. This will
    # only work if your application is hosted on the same domain as the
    # web page in which it is embedded.
    #
    setAjaxMethod(XMLHttpRequest)
    top = nil
    setTitle("Hello world")

    if !embedded
      #
      # In Application mode, we have the root is a container
      # corresponding to the entire browser window
      #
      top = root
    else
      #
      # In WidgetSet mode, we create and bind containers to existing
      # divs in the web page. In self example, we create a single div
      # whose DOM id was passed as a request argument.
      #
      top = Wt::WContainerWidget.new
      div = env.getParameter("div")
      if div
        bindWidget(top, div)
      else
        $stderr.puts("Missing: parameter: 'div'")
        return
      end
    end

    if !embedded
      Wt::WText.new(  "<p><emph>Note: you can also run this application " \
                      "from within <a href=\"hello.html\">a web page</a>.</emph></p>",
                      root )
    end

    #
    # Everything else is business as usual.
    #
    top.addWidget(Wt::WText.new("Your name, please ? "))
    @nameEdit = Wt::WLineEdit.new(top)
    @nameEdit.setFocus

    b = Wt::WPushButton.new("Greet me.", top)
    b.setMargin(Wt::WLength.new(5), Wt::Left)

    top.addWidget(Wt::WBreak.new)

    @greeting = Wt::WText.new(top)

    #
    # Connect signals with slots
    #
    b.clicked.connect(SLOT(self, :greet))
    @nameEdit.enterPressed.connect(SLOT(self, :greet))
  end

  def greet
    #
    # Update the text, using text input into the @nameEdit field.
    #
    @greeting.text = "Hello there, " + @nameEdit.text
  end
end

server = Wt::WServer.new($0)

# Use default server configuration: command line arguments and the
# wthttpd configuration file.
server.setServerConfiguration(ARGV, WTHTTP_CONFIGURATION)

# Application entry points. Each entry point binds an URL with an
# application (with a callback function used to bootstrap a new
# application).

# The following is the default entry point. It configures a
# standalone Wt application at the deploy path configured in the
# server configuration.
server.addEntryPoint(Wt::WServer::Application) do |env|
  HelloApplication.new(env, false)
end

# The following adds an entry point for a widget set. A widget set
# must be loaded as a JavaScript from an HTML page.
server.addEntryPoint(Wt::WServer::WidgetSet, "hello.wtjs") do |env|
  HelloApplication.new(env, true)
end

# Start the server (in the background if there is threading support)
# and wait for a shutdown signal (e.g. Ctrl C, SIGKILL)
if server.start
  Wt::WServer.waitForShutdown

  # Cleanly terminate all sessions
  server.stop
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
