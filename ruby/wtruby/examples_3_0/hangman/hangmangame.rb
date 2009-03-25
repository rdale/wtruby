# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#

class HangmanGame < Wt::WTable
  # Show the initial screen
  def initialize(parent)
    super(parent)
    resize(Wt::WLength.new(100, Wt::WLength::Percentage), Wt::WLength::Auto)
  
    title = Wt::WText.new("A Witty game: Hangman", elementAt(0,0))
    title.decorationStyle.font.size = Wt::WFont::XXLarge
  
    # Center the title horizontally.
    elementAt(0, 0).contentAlignment = Wt::AlignTop | Wt::AlignCenter
  
    # Element (1,1) holds a stack of widgets with the main content.
    # This is where we switch between @login, @game, and Highscores widgets.
    @mainStack = Wt::WStackedWidget.new(elementAt(1, 0))
    @mainStack.padding = Wt::WLength.new(20)
  
    @login = LoginWidget.new
    @mainStack.addWidget(@login)
    @login.loginSuccessful.connect(SLOT(self, :play))
  
    # Element (2,0) contains navigation buttons. Instead of WButton,
    # we use Wt::WText. Wt::WText inherits from Wt::WInteractWidget, and thus exposes
    # the click event.
    @backToGameText = Wt::WText.new(" Gaming Grounds ", elementAt(2, 0))
    @backToGameText.decorationStyle.cursor = Wt::PointingHandCursor
    @backToGameText.clicked.connect(SLOT(self, :showGame))
  
    @scoresText = Wt::WText.new(" Highscores ", elementAt(2, 0))
    @scoresText.decorationStyle.cursor = Wt::PointingHandCursor
    @scoresText.clicked.connect(SLOT(self, :showHighScores))
    # Center the buttons horizontally.
    elementAt(2, 0).contentAlignment = Wt::AlignTop | Wt::AlignCenter
  
    doLogin
  end

  def doLogin
    @mainStack.currentWidget = @login
    @backToGameText.hide
    @scoresText.hide
  end

  def play(user, dict)
    # Add a widget by passing @mainStack as the parent, ...
    @game = HangmanWidget.new(user, dict, @mainStack)
    # ... or using addWidget
    @mainStack.addWidget(@scores = HighScoresWidget.new(user))
  
    @backToGameText.show
    @scoresText.show
  
    showGame
  end

  def showHighScores
    @mainStack.currentWidget = @scores
    @scores.update
    @backToGameText.decorationStyle.font.weight = Wt::WFont::NormalWeight
    @scoresText.decorationStyle.font.weight = Wt::WFont::Bold
  end

  def showGame
    @mainStack.currentWidget = @game
    @backToGameText.decorationStyle.font.weight = Wt::WFont::Bold
    @scoresText.decorationStyle.font.weight = Wt::WFont::NormalWeight
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
