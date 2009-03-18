#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
#  composerexample
#
# A label.
#
# A label is a WText that is styled as "label", and aligned
# to the right in its parent.
#
class Label < Wt::WText
#@}*/
#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#



  def initialize(text, parent)
    super(text, parent)
  setStyleClass("label")
  parent.contentAlignment = Wt::AlignRight
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
