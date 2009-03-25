#!/usr/bin/env ruby
#
# Copyright (C) 2006 Koen Deforche
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'
require 'countdownwidget.rb'

Wt::WRun(ARGV) do |env|
  appl = Wt::WApplication.new(env)

  Wt::WText.new("<h1>Your mission</h1>", appl.root)
  secret = Wt::WText.new( "Your mission, Jim, should you accept, is to create solid " +
                          "web applications.",
                          appl.root )

  Wt::WBreak.new(appl.root)
  Wt::WBreak.new(appl.root)

  Wt::WText.new("This program will quit in ", appl.root)
  countdown = CountDownWidget.new(10, 0, 1000, appl.root)
  Wt::WText.new(" seconds.", appl.root)

  Wt::WBreak.new(appl.root) 
  Wt::WBreak.new(appl.root)

  cancelButton = Wt::WPushButton.new("Cancel!", appl.root)
  quitButton = Wt::WPushButton.new("Quit", appl.root)
  quitButton.clicked.connect(SLOT(appl, :quit))

  countdown.done.connect(SLOT(appl, :quit))
  cancelButton.clicked.connect(SLOT(countdown, :cancel))
  cancelButton.clicked.connect(SLOT(cancelButton, :disable))
  cancelButton.clicked.connect(SLOT(secret, :hide))

  appl
end
