#
# Copyright (C) 2007 Koen Deforche
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

# Chat example
#
# A self-contained chat widget.
#
class SimpleChatWidget < Wt::WContainerWidget
 #! \brief Create a chat widget that will connect to the given server.
  #
 #! \brief Delete a chat widget.
  #
 #! \brief Show a simple login screen.
  #
 #! \brief Start a chat for the given user.
  #
  # Returns false if the user could not login.
  #
 # called from another session */

  def initialize(server, parent)
    super(parent)
    @server = server
    @app = Wt::WApplication.instance
    @user = @server.suggestGuest
    letLogin

    @app.enableUpdates
  end

  def letLogin
    clear
  
    vLayout = Wt::WVBoxLayout.new
    setLayout(vLayout, Wt::AlignLeft | Wt::AlignTop)
  
    hLayout = Wt::WHBoxLayout.new
    vLayout.addLayout(hLayout)
  
    hLayout.addWidget(Wt::WLabel.new("User name:"), 0, AlignMiddle)
    hLayout.addWidget(@userNameEdit = Wt::WLineEdit.new(@user), 0, Wt::AlignMiddle)
    @userNameEdit.setFocus
  
    b = Wt::WPushButton.new("Login")
    hLayout.addWidget(b, 0, Wt::AlignMiddle)
    hLayout.addStretch(1)
  
    b.clicked.connect(SLOT(self, :login))
    @userNameEdit.enterPressed.connect(SLOT(self, :login))
  
    vLayout.addWidget(@statusMsg = Wt::WText.new)
    @statusMsg.formatting = Wt::WText::PlainFormatting
  end

  def login
    name = Wt::WWebWidget.escapeText(@userNameEdit.text)
  
    if !startChat(name)
      @statusMsg.setText("Sorry, name '" + name + "' is already taken.")
    end
  end

  def logout
    if @eventConnection.connected
      @eventConnection.disconnect # do not listen for more events
      @server.logout(@user)
  
      letLogin
    end
  end

  def startChat(user)
    if @server.login(user)
      @eventConnection = @server.chatEvent.connect(SLOT(self, :processChatEvent))
      @user = user
      clear

      #
      # Create a vertical layout, which will hold 3 rows,
      # organized like self:
      #
      # Wt::WVBoxLayout
      # --------------------------------------------
      # | nested Wt::WHBoxLayout (vertical stretch=1)  |
      # |                              |           |
      # |  messages                    | userslist |
      # |   (horizontal stretch=1)     |           |
      # |                              |           |
      # --------------------------------------------
      # | message edit area                        |
      # --------------------------------------------
      # | Wt::WHBoxLayout                              |
      # | send | logout |       stretch = 1        |
      # --------------------------------------------
      #
      vLayout = Wt::WVBoxLayout.new
  
      # Create a horizontal layout for the messages | userslist.
      hLayout = Wt::WHBoxLayout.new
  
      # Add widget to horizontal layout with stretch = 1
      hLayout.addWidget(@messages = Wt::WContainerWidget.new, 1)
      @messages.styleClass = "chat-msgs"
      # Display scroll bars if contents overflows
      @messages.overflow = Wt::WContainerWidget::OverflowAuto
  
      # Add another widget to hirozontal layout with stretch = 0
      hLayout.addWidget(@userList = Wt::WContainerWidget.new)
      @userList.styleClass = "chat-users"
      @userList.overflow = Wt::WContainerWidget::OverflowAuto
  
      # Add nested layout to vertical layout with stretch = 1
      vLayout.addLayout(hLayout, 1)
  
      # Add widget to vertical layout with stretch = 0
      vLayout.addWidget(@messageEdit = Wt::WTextArea.new)
      @messageEdit.styleClass = "chat-noedit"
      @messageEdit.rows = 2
      @messageEdit.setFocus
  
      # Create a horizontal layout for the buttons.
      hLayout = Wt::WHBoxLayout.new
  
      # Add button to horizontal layout with stretch = 0
      @sendButton = Wt::WPushButton.new("Send")
      hLayout.addWidget(@sendButton)
  
      # Add button to horizontal layout with stretch = 0
      b = Wt::WPushButton.new("Logout", self)
      hLayout.addWidget(b)
  
      # Add stretching spacer to horizontal layout
      hLayout.addStretch(1)
  
      # Add nested layout to vertical layout with stretch = 0
      vLayout.addLayout(hLayout)
  
      setLayout(vLayout)
  
      #
      # Connect event handlers
      #
      @sendButton.clicked.connect(SLOT(@sendButton, :disable))
      @sendButton.clicked.connect(SLOT(@messageEdit, :disable))
      @sendButton.clicked.connect(SLOT(self, :send))
  
      @messageEdit.enterPressed.connect(SLOT(@sendButton, :disable))
      @messageEdit.enterPressed.connect(SLOT(@messageEdit, :disable))
      @messageEdit.enterPressed.connect(SLOT(self, :send))
  
      b.clicked.connect(SLOT(self, :logout))
  
      msg = Wt::WText.new(false,
        "<span class='chat-info'>You are joining the conversation as " +
        @user + "</span>", @messages)
      msg.styleClass = "chat-msg"
  
      updateUsers
      
      return true
    else
      return false
    end
  end

  def send
    if !@messageEdit.text.empty
      @server.sendMessage(@user, @messageEdit.text)
      @messageEdit.text = ""
    end
  
    @messageEdit.enable
    @messageEdit.setFocus
    @sendButton.enable
  end

  def updateUsers
    @userList.clear

    users = @server.users


   for (SimpleChatServer::UserSet::iterator i = users.begin i != users.end; i += 1) {
      if #i == @user
        usersStr += "<span class='chat-self'>" + *i + "</span><br />"
      end
      else
        usersStr += *i + "<br />"
    end
  
    @userList.addWidget(Wt::WText.new(false, usersStr))
  end

  def processChatEvent(event)
    #
    # This is where the "server-push" happens. This method is called
    # when a event.new or message needs to be notified to the user. In
    # general, it is called from another session.
    #
    # First, we take the lock to safely manipulate the UI outside of the
    # normal event loop.
    #
  
    lock = Wt::WApplication::UpdateLock.new = @app.getUpdateLock
  
    w = Wt::WText.new(false, event.formattedHTML(@user), @messages)
    w.styleClass = "chat-msg"
  
    # no more than 100 messages back-log */
    if @messages.count > 100
      delete @messages.children[0]
    end
  
    if event.type != ChatEvent::Message
      updateUsers
    end
  
    #
    # little javascript trick to make sure we scroll along with content.new
    #
    @app.doJavaScript(@messages.jsRef + ".scrollTop += " + @messages.jsRef + ".scrollHeight;")
  
    @app.triggerUpdate
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
