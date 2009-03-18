#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

#  composerexample
#
# An E-mail composer widget.
#
# This widget is part of the Wt composer example.
#
class Composer < Wt::WCompositeWidget
  attr_reader :send_mail, :discard

  def initialize(parent)
    super(parent)
    @saving = false
    @sending = false
    @send_mail = Wt::Signal.new
    @discard = Wt::Signal.new
    @attachments = []
    setImplementation(@layout = Wt::WContainerWidget.new)

    createUi
  end

  def to=(to)
    @toEdit.addressees = to
  end

  def subject=(subject)
    @subject.text = subject
  end

  def message=(message)
    @message.text = message
  end

  def to
    return @toEdit.addressees
  end

  def cc
    return @ccEdit.addressees
  end
 
  def bcc
    return @bccEdit.addressees
  end

  def addressBook=(contacts)
    @contactSuggestions.addressBook = contacts
  end

  def subject
    return @subject.text
  end

  def attachments
    attachments = []
  
    @attachments.each do |attachment|
      if attachment.include_attachment?
        attachments.push(attachment)
      end
    end
  
    return attachments
  end

  def message
    return @message.text
  end

  def createUi
    setStyleClass("darker")
  
    #
    # Top buttons
    #
    horiz = Wt::WContainerWidget.new(@layout)
    horiz.margin = Wt::WLength.new(5)
    @topSendButton = Wt::WPushButton.new(tr("msg.send"), horiz)
    @topSendButton.styleClass = "default"
    @topSaveNowButton = Wt::WPushButton.new(tr("msg.savenow"), horiz)
    @topDiscardButton = Wt::WPushButton.new(tr("msg.discard"), horiz)
  
    # Text widget which shows status messages, next to the top buttons.
    @statusMsg = Wt::WText.new(horiz)
    @statusMsg.setMargin(Wt::WLength.new(15), Wt::Left)
  
    #
    # To, Cc, Bcc, Subject, Attachments
    #
    # They are organized in a two-column table: left column for
    # labels, and right column for the edit.
    #
    @edits = Wt::WTable.new(@layout)
    @edits.styleClass = "lighter"
    @edits.resize(Wt::WLength.new(100, Wt::WLength::Percentage), Wt::WLength::Auto)
    @edits.elementAt(0, 0).resize(Wt::WLength.new(1, Wt::WLength::Percentage), Wt::WLength::Auto)
  
    #
    # To, Cc, Bcc
    #
    @toEdit = AddresseeEdit.new(tr("msg.to"), @edits.elementAt(0, 1),
                                @edits.elementAt(0, 0))
    # add some space above To:
    @edits.elementAt(0, 1).setMargin(Wt::WLength.new(5), Wt::Top)
    @ccEdit = AddresseeEdit.new(tr("msg.cc"), @edits.elementAt(1, 1),
                                @edits.elementAt(1, 0))
    @bccEdit = AddresseeEdit.new(tr("msg.bcc"), @edits.elementAt(2, 1),
                                @edits.elementAt(2, 0))
  
    @ccEdit.hide
    @bccEdit.hide
  
    #
    # Addressbook suggestions popup
    #
    @contactSuggestions = ContactSuggestions.new(@layout)
    @contactSuggestions.styleClass = "suggest"
  
    @contactSuggestions.forEdit(@toEdit)
    @contactSuggestions.forEdit(@ccEdit)
    @contactSuggestions.forEdit(@bccEdit)
  
    #
    # We use an OptionList widget to show the expand options for
    # @ccEdit and @bccEdit nicely next to each other, separated
    # by pipe characters.
    #
    @options = OptionList.new(@edits.elementAt(3, 1))
  
    @options.add(@addcc = Option.new(tr("msg.addcc")))
    @options.add(@addbcc = Option.new(tr("msg.addbcc")))
  
    #
    # Subject
    #
    Label.new(tr("msg.subject"), @edits.elementAt(4, 0))
    @subject = Wt::WLineEdit.new(@edits.elementAt(4, 1))
    @subject.resize(Wt::WLength.new(99, Wt::WLength::Percentage), Wt::WLength::Auto)
  
    #
    # Attachments
    #
    Wt::WImage.new("icons/paperclip.png", @edits.elementAt(5, 0))
    @edits.elementAt(5, 0).contentAlignment = Wt::AlignRight | Wt::AlignTop
  
    
    # Attachment edits: we always have the next attachmentedit ready
    # but hidden. This improves the response time, since the show
    # and hide slots are stateless.
    @attachments.push(AttachmentEdit.new(self, @edits.elementAt(5, 1)))
    @attachments.last.hide
  
    #
    # Two options for attaching files. The first does not say 'another'.
    #
    @attachFile = Option.new(tr("msg.attachfile"),
                            @edits.elementAt(5, 1))
    @attachOtherFile = Option.new(tr("msg.attachanother"),
                                  @edits.elementAt(5, 1))
    @attachOtherFile.hide
  
    #
    # Message
    #
    @message = Wt::WTextArea.new(@layout)
    @message.columns = 80
    @message.rows = 10
    @message.margin = Wt::WLength.new(10)
  
    #
    # Bottom buttons
    #
    horiz = Wt::WContainerWidget.new(@layout)
    horiz.margin = Wt::WLength.new(5)
    @botSendButton = Wt::WPushButton.new(tr("msg.send"), horiz)
    @botSendButton.styleClass = "default"
    @botSaveNowButton = Wt::WPushButton.new(tr("msg.savenow"), horiz)
    @botDiscardButton = Wt::WPushButton.new(tr("msg.discard"), horiz)
  
    #
    # Button events.
    #
    @topSendButton.clicked.connect(SLOT(self, :sendIt))
    @botSendButton.clicked.connect(SLOT(self, :sendIt))
    @topSaveNowButton.clicked.connect(SLOT(self, :saveNow))
    @botSaveNowButton.clicked.connect(SLOT(self, :saveNow))
    @topDiscardButton.clicked.connect(SLOT(self, :discardIt))
    @botDiscardButton.clicked.connect(SLOT(self, :discardIt))
  
    #
    # Option events to show the cc or Bcc edit.
    #
    # Clicking on the option should both show the corresponding edit, and
    # hide the option itself.
    #
    @addcc.item.clicked.connect(SLOT(@ccEdit, :show))
    @addcc.item.clicked.connect(SLOT(@addcc, :hide))
    @addcc.item.clicked.connect(SLOT(@options, :update))
  
    @addbcc.item.clicked.connect(SLOT(@bccEdit, :show))
    @addbcc.item.clicked.connect(SLOT(@addbcc, :hide))
    @addbcc.item.clicked.connect(SLOT(@options, :update))
  
    #
    # Option event to attach the first attachment.
    #
    # We show the first attachment, and call attachMore to prepare the
    # next attachment edit that will be hidden.
    #
    # In addition, we need to show the 'attach More' option, and hide the
    # 'attach' option.
    #
    @attachFile.item.clicked.connect(SLOT(@attachments.last, :show))
    @attachFile.item.clicked.connect(SLOT(@attachOtherFile, :show))
    @attachFile.item.clicked.connect(SLOT(@attachFile, :hide))
    @attachFile.item.clicked.connect(SLOT(self, :attachMore))
    @attachOtherFile.item.clicked.connect(SLOT(self, :attachMore))
  end

  def attachMore
    #
    # Create and append the next @attachmentEdit, that will be hidden.
    #
    edit = AttachmentEdit.new(self)
    @edits.elementAt(5, 1).insertBefore(edit, @attachOtherFile)
    @attachments.push(edit)
    @attachments.last.hide
  
    # Connect the @attachOtherFile option to show self attachment.
    @attachOtherFile.item.clicked.connect(SLOT(@attachments.last, :show))
  end

  def removeAttachment(attachment)
    #
    # Remove the given attachment from the attachments list.
    #
    @attachments.delete(attachment)
    if @attachments.length == 1
      #
      # This was the last visible attachment, thus, we should switch
      # the option control again.
      #
      @attachOtherFile.hide
      @attachFile.show
      @attachFile.item.clicked.connect(SLOT(@attachments.last, :show))
    end
  end

  def sendIt
    if !@sending
      @sending = true
  
      #
      # First save -- this will check for the sending state
      # signal if successfull.
      #
      saveNow
    end
  end

  def saveNow
    if !@saving
      @saving = true
  
      #
      # Check if any attachments still need to be uploaded.
      # This may be the case when fileupload change events could not
      # be caught (for example in Konqueror).
      #
      @attachmentsPending = 0
  
      @attachments.each do |attachment|
        if attachment.uploadNow
          @attachmentsPending += 1
  
          # this will trigger attachmentDone when done, see
          # the AttachmentEdit constructor.
        end
      end
  
      puts "Attachments pending: #{@attachmentsPending}"
      if @attachmentsPending
        setStatus(tr("msg.uploading"), "status")
      else
        saved
      end
    end
  end

  def attachmentDone
    if @saving
      @attachmentsPending -= 1
      puts "Attachments still: #{@attachmentsPending}"
  
      if @attachmentsPending == 0
        saved
      end
    end
  end

  def setStatus(text,  style)
    @statusMsg.text = text
    @statusMsg.styleClass = style
  end

  def saved
    #
    # All attachments have been processed.
    #
    attachmentsFailed = false
    for i in 0...(@attachments.length - 1) do
      if @attachments[i].uploadFailed
        attachmentsFailed = true
        break
      end
    end

    if attachmentsFailed
      setStatus(tr("msg.attachment.failed"), "error")
    else
      setStatus(tr("msg.ok"), "status")
      @statusMsg.text = "Draft saved at " + Time.now.strftime("%H:%M")
  
      if @sending
        @send_mail.emit
        return
      end
    end
  
    @saving = false
    @sending = false
  end

  def discardIt
    @discard.emit
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
