#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

#
# missionexample Timer example
#
#A widget which displays a decrementing number.
#
class CountDownWidget < Wt::WText
  #
  # Signal emitted when the countdown reaches stop.
  attr_reader :done

  # Create a new CountDownWidget.
  #
  # The widget will count down from start to stop, decrementing
  # the number every msec milliseconds.
  def initialize(start, stop, msec, parent)
    super(parent)
    @start = start
    @stop = stop
    @stop = [@start - 1, @stop].min  # stop must be smaller than start
    @current = @start
    @done = Wt::Signal.new

    @timer = Wt::WTimer.new(self)
    @timer.interval = msec
    @timer.timeout.connect(SLOT(self, :timerTick))
    @timer.start

    setText(@current.to_s)
  end

  # Cancel the count down.
  def cancel
    @timer.stop
  end

  # Process one timer tick.
  def timerTick
    setText((@current -= 1).to_s)

    if @current <= @stop
      @timer.stop
      @done.emit
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
