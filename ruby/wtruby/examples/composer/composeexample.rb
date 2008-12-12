#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

require 'wt'

require 'addresseeedit.rb'
require 'attachmentedit.rb'
require 'composeexample.rb'
require 'composer.rb'
require 'contact.rb'
require 'contactsuggestions.rb'
require 'label.rb'
require 'optionlist.rb'
require 'option.rb'

#  composerexample Composer example
#
# Main widget of the Composer example.
#
class ComposeExample < Wt::WContainerWidget
 # create a new Composer example.

  def initialize(parent = nil)
    super(parent)
    @composer = Composer.new(self)
  
    addressBook = []
    addressBook.push(Contact.new("Koen Deforche", "koen.deforche@gmail.com"))
    addressBook.push(Contact.new("Koen alias1", "koen.alias1@yahoo.com"))
    addressBook.push(Contact.new("Koen alias2", "koen.alias2@yahoo.com"))
    addressBook.push(Contact.new("Koen alias3", "koen.alias3@yahoo.com"))
    addressBook.push(Contact.new("Bartje", "jafar@hotmail.com"))
    @composer.addressBook = addressBook
  
    contacts = []
    contacts.push(Contact.new("Koen Deforche", "koen.deforche@gmail.com"))
  
    @composer.to = contacts
    @composer.subject = "That's cool! Want to start your own google?"
  
    @composer.send_mail.connect(SLOT(self, :send_mail))
    @composer.discard.connect(SLOT(self, :discard))
  
    @details = Wt::WContainerWidget.new(self)
  
    Wt::WText.new(tr("example.info"), @details)
  end

  def send_mail
    feedback = Wt::WContainerWidget.new(self)
    feedback.styleClass = "feedback"
  
    horiz = Wt::WContainerWidget.new(feedback)
    Wt::WText.new("<p>We could have, but did not send the following email:</p>", horiz)
  
    contacts = @composer.to
    if !contacts.empty?
      horiz = Wt::WContainerWidget.new(feedback)
    end
    contacts.each do |contact|
      Wt::WText.new('To: "' + contact.name + '" <' +
                    contact.email + ">", Wt::PlainText, horiz)
      Wt::WBreak.new(horiz)
    end
  
    contacts = @composer.cc
    if !contacts.empty?
      horiz = Wt::WContainerWidget.new(feedback)
    end
    contacts.each do |contact|
      Wt::WText.new('Cc: "' + contact.name + '" <' +
                    contact.email + ">", Wt::PlainText, horiz)
      Wt::WBreak.new(horiz)
    end
    
    contacts = @composer.bcc
    if !contacts.empty?
      horiz = Wt::WContainerWidget.new(feedback)
    end
    contacts.each do |contact|
      Wt::WText.new('Bcc: "' + contact.name + '" <' +
                    contact.email + ">", Wt::PlainText, horiz)
      Wt::WBreak.new(horiz)
    end
  
    horiz = Wt::WContainerWidget.new(feedback)
    t = Wt::WText.new('Subject: "' + @composer.subject + '"',
                        Wt::PlainText, horiz)
  
    attachments = @composer.attachments
    if !attachments.empty?
      horiz = Wt::WContainerWidget.new(feedback)
    end
    attachments.each do |attachment|
      Wt::WText.new("Attachment: \"" +
                    attachment.fileName +
                    "\" (" + attachment.contentDescription +
                    ")", Wt::PlainText, horiz)
  
      File.unlink(attachment.spoolFileName)
  
      Wt::WText.new(", was in spool file: " +
                    attachment.spoolFileName, horiz)
      Wt::WBreak.new(horiz)
    end
  
    message = @composer.message
  
    horiz = Wt::WContainerWidget.new(feedback)
    t = Wt::WText.new("Message body: ", horiz)
    Wt::WBreak.new(horiz)
  
    if !message.empty?
      t = Wt::WText.new(message, Wt::PlainText, horiz)
    else
      t = Wt::WText.new("<i>(empty)</i>", horiz)
    end
  
    # delete @composer
    @composer.hide
    # delete @details
    @details.hide
  
    $wApp.quit
  end

  def discard
    feedback = Wt::WContainerWidget.new(self)
    feedback.styleClass = "feedback"
  
    horiz = Wt::WContainerWidget.new(feedback)
    Wt::WText.new("<p>Wise decision! Everyone's mailbox is already full anyway.</p>",
              horiz)
  
    # delete @composer
    # delete @details
  
    $wApp.quit
  end
end

Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)

  # The following assumes composer.xml is in the webserver working directory
  # (but does not need to be deployed within docroot):
  app.messageResourceBundle.use("composer")

  # The following assumes composer.css is deployed in the seb server at the
  # same location as the application:
  app.useStyleSheet("composer.css")

  app.title = "Composer example"

  app.root.addWidget(ComposeExample.new)

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
