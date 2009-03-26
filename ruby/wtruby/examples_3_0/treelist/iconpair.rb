#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
#  treelist
#
# An icon pair (identical to WIconPair)
#
# This widget manages two images, only one of which is shown at a single
# time.
#
# The widget may also react to click events, by changing state.
#
# This widget is part of the %Wt treelist example, where it is used
# to represent the expand/collapse icons, and the corresponding
# map open/close icon.
#
# \sa TreeNode
#
class IconPair < Wt::WCompositeWidget
  attr_reader :icon1Clicked, :icon2Clicked, :icon1, :icon2

  # Construct a two-state icon widget.
  #
  # The constructor takes the URI of the two icons. When clickIsSwitch
  # is set true, clicking on the icon will switch state.
  #
  def initialize(icon1URI, icon2URI, clickIsSwitch = true, parent = nil)
    super(parent)
    @impl = Wt::WContainerWidget.new
    @icon1 = Wt::WImage.new(icon1URI, @impl)
    @icon2 = Wt::WImage.new(icon2URI, @impl)
    @icon1Clicked = @icon1.clicked
    @icon2Clicked = @icon2.clicked
    setImplementation(@impl)

    implementStateless(:showIcon1, :undoShowIcon1)
    implementStateless(:showIcon2, :undoShowIcon2)

    setInline(true)

    @icon2.hide

    if clickIsSwitch
      @icon1.clicked.connect(SLOT(@icon1, :hide))
      @icon1.clicked.connect(SLOT(@icon2, :show))
  
      @icon2.clicked.connect(SLOT(@icon2, :hide))
      @icon2.clicked.connect(SLOT(@icon1, :show))
  
      decorationStyle.cursor = Wt::PointingHandCursor
    end
  end

  def state=(num)
    setState(num)
  end

  def setState(num)
    if num == 0
      @icon1.show
      @icon2.hide
    else
      @icon1.hide
      @icon2.show
    end
  end

  def state
    return (@icon1.isHidden ? 1 : 0)
  end

  def showIcon1
    @previousState = (@icon1.isHidden ? 1 : 0)
    setState(0)
  end

  def showIcon2
    @previousState = (@icon1.isHidden ? 1 : 0)
    setState(1)
  end

  def undoShowIcon1
    setState(@previousState)
  end

  def undoShowIcon2
    setState(@previousState)
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
