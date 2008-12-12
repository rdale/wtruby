#
# Copyright (C) 2007 Koen Deforche
#
# See the LICENSE file for terms of use.
#
#*
# @addtogroup chatexample
#
#@{*/
#! \brief Encapsulate a chat event.
#
class ChatEvent
  attr_accessor :type, :user, :message
  # Enumeration for the event type.
  Login = 0
  Logout = 1
  Message = 2

  /*
   * Both user and html will be formatted as html
   */
  def initialize(user, type = Message, message = nil)
    type = Message
    @user = user
    @message = message
  end
const WString ChatEvent::formattedHTML(const WString& user) const
  switch (@type) {
  case Login:
    return "<span class='chat-info'>"
      + @user + " joined the conversation.</span>"
  case Logout:
    return "<span class='chat-info'>"
      + ((user == @user) ? "You" : @user)
      + " logged out.</span>"
  case Message:{
    WString result

    result = WString("<span class='")
      + ((user == @user) ? "chat-self" : "chat-user")
      + "'>" + @user + ":</span>"

    if @message.toUTF8.find(user.toUTF8) != std::string::npos
      return result + "<span class='chat-highlight'>" + @message + "</span>"
    end
    else
      return result + @message
    end
  default:
    return ""
    end
  end
end

#! \brief A simple chat server
#
class SimpleChatServer < Wt::WObject

  def initialize
    @chatEvent = Wt::Signal.new()
  end

  def login(user)
  #boost::mutex::scoped_lock lock(@mutex)
  
    if @users.find(user) == @users.end
      @users.insert(user)

      chatEvent.emit(ChatEvent.new(ChatEvent::Login, user))

      return true
    else
      return false
    end
  end

  def logout(user)
    # boost::mutex::scoped_lock lock(@mutex)
  
    i = @users.find(user)

    if i != @users.end
      @users.erase(i)

      chatEvent.emit(ChatEvent(ChatEvent::Logout, user))
    end
  end

  def suggestGuest
    # boost::mutex::scoped_lock lock(@mutex)

    for (int i = 1;; i += 1) {
      "guest " + i.to_s
      ss = s
  
      if @users.find(ss) == @users.end
        return ss
      end
    end
  end

  def sendMessage(user, message)
    #boost::mutex::scoped_lock lock(@mutex)
  
    chatEvent.emit(ChatEvent(user, message))
  end

  def users
    return @users
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
