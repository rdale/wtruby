#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richard Dale

#
# A specialized treeview that supports a custom drop event.
#
class FolderView < Wt::WTreeView

  FILE_SELECTION_MIME_TYPE = "application/x-computers-selection"

  def initialize(parent = nil)
    super(parent)
    #
    # Accept drops for the custom mime type.
    #
    acceptDrops(FILE_SELECTION_MIME_TYPE)
  end

  def dropEvent(event, target)
    #
    # We reimplement the drop event to handle the dropping of a
    # selection of computers.
    #
    # The test below would always be true in self case, since we only
    # indicated support for that particular mime type.
    #
    if event.mimeType == FILE_SELECTION_MIME_TYPE
      #
      # The source object for a drag of a selection from a WTreeView is
      # a WItemSelectionModel.
      #
      selection = event.source

      result = Wt::WMessageBox::show("Drop event",
        "Move #{selection.selectedIndexes.length} files to folder '#{target.data(Wt::DisplayRole)}'?",
        Wt::Yes | Wt::No)

      if result == Wt::Yes
        #
        # You can access the source model from the selection and
        # manipulate it.
        #
        sourceModel = selection.model

        toChange = selection.selectedIndexes
        toChange.each do |i|
          index = Wt::WModelIndex.new(i)

          #
          # Copy target folder to file. Since we are using a
          # dynamic WSortFilterProxyModel that filters on folder, self
          # will also result in the removal of the file from the
          # current view.
          #
          data = model.itemData(target)
          data[Wt::DecorationRole] = index.data(Wt::DecorationRole)
          sourceModel.setItemData(index, data)
        end
      end
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
