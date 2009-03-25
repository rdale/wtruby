#
# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#

class HangmanWidget < Wt::WContainerWidget

  def initialize(user, dict, parent)
    super(parent)
    @maxGuesses = 9
    @user = user
    @dict = dict
    @hangmanImages = []
    @letterButtons = []
    @wordLetters = []
    setContentAlignment(Wt::AlignCenter)
  
    @title = Wt::WText.new("Guess the word!", self)
    @title.decorationStyle.font.size = Wt::WFont::XLarge
  
    @wordContainer = Wt::WContainerWidget.new(self)
    @wordContainer.setMargin(Wt::WLength.new(20), Wt::Top | Wt::Bottom)
    @wordContainer.contentAlignment = Wt::AlignCenter
    style = @wordContainer.decorationStyle
    style.border = Wt::WBorder.new(Wt::WBorder::Solid)
    style.font.setFamily(Wt::WFont::Monospace, "courier")
    style.font.size = Wt::WFont::XXLarge
  
    @statusText = Wt::WText.new(self)
    Wt::WBreak.new(self)
    createHangmanImages(self)
    createAlphabet(self)
    Wt::WBreak.new(self)
    @newGameButton = Wt::WPushButton.new("New Game", self)
    @newGameButton.clicked.connect(SLOT(self, :newGame))
  
    # prepare for first game
    newGame
  end

  def createHangmanImages(parent)
   for i in 0..@maxGuesses
      fname = "icons/hangman"
      fname += i.to_s + ".png"
      theImage = Wt::WImage.new(fname, parent)
      @hangmanImages.push(theImage)

      # Although not necessary, we can avoid flicker (on konqueror)
      # by presetting the image size.
      theImage.resize(Wt::WLength.new(256), Wt::WLength.new(256))
     end

   @hurrayImage = Wt::WImage.new("icons/hangmanhurray.png", parent)
   resetImages
  end

  def createAlphabet(parent)
    @letterButtonLayout = Wt::WTable.new(parent)
  
    # The default width of a table is 100%...
    @letterButtonLayout.resize(Wt::WLength.new(13*30), Wt::WLength::Auto)
  
    mapper = Wt::WSignalMapper.new(self)
  
    for i in 0...26
        c = (?A + i).chr
        character = Wt::WPushButton.new(c, @letterButtonLayout.elementAt(i / 13, i % 13))
        @letterButtons.push(character)
        character.resize(Wt::WLength.new(30), Wt::WLength::Auto)
        mapper.mapConnect(character.clicked, character)
      end
  
    mapper.mapped.connect(SLOT(self, :processButton))
  end

  def newGame
    @word = randomWord(@dict)
    @title.setText("Guess the word, " + @user + "!")
    @newGameButton.hide # don't let the player chicken out
  
    # Bring widget to initial state
    resetImages
    resetButtons
    @badGuesses = @displayedLetters = 0
    @hangmanImages[0].show
  
    # Prepare the widgets for the word.new
    @wordContainer.clear
    @wordLetters.clear
    for i in 0...@word.length
      c = Wt::WText.new("-", @wordContainer)
      @wordLetters.push(c)
    end

    # resize appropriately so that the border looks nice.
    @wordContainer.resize(Wt::WLength.new(@word.size * 1.5, Wt::WLength::FontEx),
                          Wt::WLength::Auto)
  
    @statusText.text = ""
  end

  def processButton(button)
    if !button.enabled?
      return
    end

    txt = button.text
    c = txt[0, 1]
    if @word.include? c
      registerCorrectGuess(c)
    else
      registerBadGuess
    end
    button.disable
  end

  def registerBadGuess
    if @badGuesses < @maxGuesses
      @hangmanImages[@badGuesses].hide
      @badGuesses += 1
      @hangmanImages[@badGuesses].show
      if @badGuesses == @maxGuesses
        @statusText.text = "You hang... <br />The correct answer was: " + @word
        @letterButtonLayout.hide
        @newGameButton.show
        HangmanDb::addToScore(@user, -10)
      end
    end
  end

  def registerCorrectGuess(c)
    for i in 0...@word.length
      if @word[i, 1] == c
        @displayedLetters += 1
        @wordLetters[i].text = c
      end
    end
    if @displayedLetters == @word.length
      @statusText.text = "You win!"
      @hangmanImages[@badGuesses].hide
      @hurrayImage.show
      @letterButtonLayout.hide
      @newGameButton.show
      HangmanDb.addToScore(@user, 20 - @badGuesses)
    end
  end

  def resetImages
    @hurrayImage.hide
    for i in 0...@hangmanImages.length
      @hangmanImages[i].hide
    end
  end

  def resetButtons
    for i in 0...@letterButtons.length
      @letterButtons[i].enable
    end
    @letterButtonLayout.show
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
