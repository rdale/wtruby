#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

#  composerexample
#
# A list of options, separated by '|'
#
# This widget is part of the %Wt composer example.
#
# An OptionList displays a list of Option widgets, which are
# separated by a '|' separator.
#
# For example, Foo | Bar | Huu
#
# When Options are hidden, the separators are adjusted so that
# there is no separator after the last visible option. However,
# self requires a call of update() each time an option is hidden
# or shown. This is because the removing of separators is optimized
# in stateless implementations, and thus in client-side JavaScript
# code. Since the behaviour is not entirely stateless, the update()
# method resets stateless implementations if necessary.
#
# \sa OptionList
#
class OptionList < Wt::WContainerWidget

  def initialize(parent)
    super(parent)
    @optionNeedReset = 0
    @options = []
    resize(Wt::WLength.new, Wt::WLength.new(2.5, Wt::WLength::FontEx))
  end

  def add(option)
    addWidget(option)
    option.optionList = self
  
    if !@options.empty?
      @options.last.addSeparator
    end
  
    @options.push(option)
  end

  def update
    if @optionNeedReset != 0
      @optionNeedReset.resetLearnedSlots
    end
  
    @optionNeedReset = 0
  end

  def optionVisibilityChanged(opt, hidden)
    #
    # Check if it was the last visible option, in that case the second last
    # visible option loses its separator.
    #
    (@options.size - 1).downto(1) do |i|
      if @options[i] == opt
        (i - 1).downto(0) do |j|
          if !@options[j].isHidden
            if hidden
              @options[j].hideSeparator
            else
              @options[j].showSeparator
            end
            break
          end
        end
        break
      else
        if !@options[i].isHidden
          break
        end
      end
    end

    #
    # The option to the right needs to relearn its stateless
    # slot code for hide and show.
    #
    for i in 0...@options.size
      if @options[i] == opt
        for j in (i + 1)...@options.size do
          if !@options[j].isHidden
            @optionNeedReset = @options[j]
            break
          end
        end
        break
      end
    end

  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
