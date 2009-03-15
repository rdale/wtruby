#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
#  composerexample
#
# An edit field for an email attachment.
#
# This widget managements one attachment edit: it shows a file upload
# control, handles the upload, and gives feed-back on the file
# uploaded.
#
# This widget is part of the Wt composer example.
#
class AttachmentEdit < Wt::WContainerWidget
  attr_reader :uploadFailed, :fileName, 
              :contentDescription, :spoolFileName

  def initialize(composer, parent = nil)
    super(parent)
    @composer = composer
    @uploadFailed = false
    @uploadDone = Wt::Signal.new
    @taken = false
    #
    # The file upload itself.
    #
    @upload = Wt::WFileUpload.new(self)
    @upload.fileTextSize = 40
  
    #
    # The 'remove' option.
    #
    @remove = Option.new(tr("msg.remove"), self)
    @upload.decorationStyle.font.size = Wt::WFont::Smaller
    @remove.setMargin(Wt::WLength.new(5), Wt::Left)
    @remove.item.clicked.connect(SLOT(self, :hide))
    @remove.item.clicked.connect(SLOT(self, :remove))

    #
    # Fields that will display the feedback.
    #

    # The check box to include or exclude the attachment.
    @keep = Wt::WCheckBox.new(self)
    @keep.hide
  
    # The uploaded file information.
    @uploaded = Wt::WText.new("", self)
    @uploaded.styleClass = "option"
    @uploaded.hide
  
    # The error message.
    @error = Wt::WText.new("", self)
    @error.styleClass = "error"
    @error.setMargin(Wt::WLength.new(5), Wt::Left)
  
    #
    # React to events.
    #
  
    # Try to catch the fileupload change signal to trigger an upload.
    # We could do like google and at a delay with a Wt::WTimer as well...
    @upload.changed.connect(SLOT(@upload, :upload))
  
    # React to a succesfull upload.
    @upload.uploaded.connect(SLOT(self, :uploaded))
  
    # React to a fileupload problem.
    @upload.fileTooLarge.connect(SLOT(self, :fileTooLarge))
  
    #
    # Connect the @uploadDone signal to the Composer's attachmentDone,
    # so that the Composer can keep track of attachment upload progress,
    # if it wishes.
    #
    @uploadDone.connect(SLOT(composer, :attachmentDone))
  end

#  AttachmentEdit::~AttachmentEdit
    # delete the local attachment file copy, if it was not taken from us.
#    if !@taken
#      unlink(@spoolFileName)
#    end
#  end

  def uploadNow
    #
    # See if self attachment still needs to be uploaded,
    # and return if a asyncrhonous.new upload is started.
    #
    if @upload
      if !@upload.isUploaded
        @upload.upload
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def uploaded
    if @upload && !@upload.emptyFileName
      @fileName = @upload.clientFileName
      @spoolFileName = @upload.spoolFileName
      @upload.stealSpooledFile
      @contentDescription = @upload.contentDescription
  
      #
      # Delete self widgets since we have a succesfull upload.
      #
      #delete @upload
      @upload.hide
      @upload = nil
      #delete @remove
      @remove.hide
      @remove = nil
  
      @error.text = ""
  
      #
      # Include the file ?
      #
      @keep.show
      @keep.setChecked
  
      #
      # Give information on the file uploaded.
      #
      buf = File.open(@spoolFileName).stat
      if buf.size < 1024
        size = buf.size.to_s + " bytes"
      else
        size = (buf.size / 1024).to_s + "kb"
      end
      @uploaded.text = @fileName + " (<i>" + @contentDescription + "</i>) " + size
      @uploaded.show
  
      @uploadFailed = false
    else
      @error.text = tr("msg.file-empty")
      @uploadFailed = true
    end
  
    #
    # Signal to the Composer that a asyncrhonous.new file upload was processed.
    #
    @uploadDone.emit
  end

  def remove
    @composer.removeAttachment(self)
  end

  def fileTooLarge(size)
    @error.text = tr("msg.file-too-large")
    @uploadFailed = true
  
    #
    # Signal to the Composer that a asyncrhonous.new file upload was processed.
    #
    @uploadDone.emit
  end

  def include_attachment?
    return @keep.isChecked
  end

  def attachment
    @taken = true
    return Attachment.new(@fileName, @contentDescription, @spoolFileName)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
