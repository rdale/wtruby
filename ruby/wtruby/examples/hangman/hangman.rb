#
# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'

require 'dictionary.rb'
require 'hangmandb.rb'
require 'hangmangame.rb'
require 'hangman.rb'
require 'hangmanwidget.rb'
require 'highscoreswidget.rb'
require 'loginwidget.rb'

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.title = "Hangman"
  HangmanGame.new(app.root)

  #
  # The application style sheet (only for the highscore widget)
  #
  cellStyle = Wt::WCssDecorationStyle.new
  cellBorder = Wt::WBorder.new
  cellBorder.style = Wt::WBorder::Solid
  cellBorder.setWidth(Wt::WBorder::Explicit, Wt::WLength.new(1))
  cellBorder.color = Wt::WColor.new(Wt::lightGray)
  cellStyle.border = cellBorder

  app.styleSheet.addRule(".TD", cellStyle)

  cellStyle.font.variant = Wt::WFont::SmallCaps

  app.styleSheet.addRule(".highscoresheader", cellStyle)

  cellStyle.font.variant = Wt::WFont::NormalVariant
  cellStyle.font.style = Wt::WFont::Italic
  cellStyle.font.weight = Wt::WFont::Bold

  app.styleSheet.addRule(".highscoresself", cellStyle)

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
