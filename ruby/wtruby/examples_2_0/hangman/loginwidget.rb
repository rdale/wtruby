# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#

class LoginWidget < Wt::WContainerWidget
  attr_reader :loginSuccessful

  def initialize(parent = nil)
    super(parent)
    @loginSuccessful = Wt::Signal2.new(self)
    setPadding(Wt::WLength.new(100), Wt::Left | Wt::Right)
  
    title = Wt::WText.new("Login", self)
    title.decorationStyle.font.size = Wt::WFont::XLarge
  
    @introText =
        Wt::WText.new("<p>Hangman keeps track of the best players. To recognise " \
                  "you, we ask you to log in. If you never logged in before, " \
                  "choose any name and password. If you don't want to be in " \
                  "our database for some reason, use the 'guest/guest' " \
                  "account.</p>" \
                  "<p>Warning: hangman contains some words and " \
                  "pictures that may offend really young players.</p>", self)
  
    layout = Wt::WTable.new(self)
    usernameLabel = Wt::WLabel.new("User name: ", layout.elementAt(0, 0))
    layout.elementAt(0, 0).resize(Wt::WLength.new(14, Wt::WLength::FontEx), Wt::WLength.new)
    @username = Wt::WLineEdit.new(layout.elementAt(0, 1))
    usernameLabel.buddy = @username
  
    passwordLabel = Wt::WLabel.new("Password: ", layout.elementAt(1, 0))
    @password = Wt::WLineEdit.new(layout.elementAt(1, 1))
    @password.echoMode = Wt::WLineEdit::Password
    passwordLabel.buddy = @password
  
    languageLabel = Wt::WLabel.new("Language: ", layout.elementAt(2, 0))
    @language = Wt::WComboBox.new(layout.elementAt(2, 1))
    @language.insertItem(0, "English words (18957 words)")
    @language.insertItem(1, "Nederlandse woordjes (1688 woorden)")
    languageLabel.buddy = @language
  
    Wt::WBreak.new(self)
  
    loginButton = Wt::WPushButton.new("Login", self)
    loginButton.clicked.connect(SLOT(self, :checkCredentials))
  end

  def checkCredentials
    @user = @username.text
    pass = @password.text
    @dict = @language.currentIndex
    
    if HangmanDb.validLogin(@user, pass)
      confirmLogin("<p>Welcome back, #{@user}.</p>")
    elsif HangmanDb.addUser(@user, pass)
      confirmLogin("<p>Welcome, #{@user}. Good luck with your first game!</p>")
    else
      @introText.setText( "<p>You entered the wrong password, or the username " \
                          "combination is already in use. If you are a returning " \
                          "user, please try again. If you are a user.new, please " \
                          "try a different name.</p>")
      @introText.decorationStyle.foregroundColor = Wt::WColor.new(Wt::red)
      @username.text = ""
      @password.text = ""
     end
  end

  def confirmLogin(text)
#   Don't call clear() for now as it causes crashes
#    clear
  
    title = Wt::WText.new("Login successful", self)
    title.decorationStyle.font.size = Wt::WFont::XLarge
  
    Wt::WText.new(text, self)
    Wt::WPushButton.new("Start playing", self).clicked.connect(SLOT(self, :startPlaying))
  end

  def startPlaying
    @loginSuccessful.emit(@user, @dict)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
