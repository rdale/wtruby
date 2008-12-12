#
# Copyright (C) 2007 Koen Deforche
#
# See the LICENSE file for terms of use.
#




#*
# @addtogroup chatexample
#
#@{*/

#! \brief The single chat server instance.
#
$theServer = SimpleChatServer.new

#! \brief A chat demo application.
#
class ChatApplication < Wt::WApplication
  void addChatWidget
  end

  def initialize(env)
    super(env))
    setTitle("Wt Chat")
    useStyleSheet("simplechat.css")
    messageResourceBundle.use("simplechat")
  
    root.addWidget(Wt::WText.new(WString::tr("introduction")))
  
    chatWidget = SimpleChatWidget.new($theServer, root)
    chatWidget.styleClass = "chat"
  
    root.addWidget(Wt::WText.new(WString::tr("details")))
  
    b = Wt::WPushButton.new("I'm schizophrenic ...", root)
    b.clicked.connect(SLOT(b, :hide))
    b.clicked.connect(SLOT(self, :addChatWidget))
  end

  def addChatWidget
    chatWidget2 = SimpleChatWidget.new($theServer, root)
    chatWidget2.styleClass = "chat"
  end
end

Wt::WRun(ARGV) do |env|
  ChatApplication.new(env)
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
