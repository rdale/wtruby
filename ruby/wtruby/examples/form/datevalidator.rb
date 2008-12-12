#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

# A validator that accepts dates.
#
# This example validator only accepts input in the dd/mm/yyyy format,
# and checks that the date is in the right range.
#
# It would be a natural thing to extend self class to provide
# access to the parsed date as a boost::gregorian::date object
# for example.
#
# This class is part of the Wt form example.
#
class DateValidator < Wt::WRegExpValidator 
  # Construct a date validator.
  #
  # The validator will accept only dates in the indicated range.
  #
  def initialize(bottom, top)
    super('(\\d{1,2})/(\\d{1,2})/(\\d{4})')
    @bottom = bottom
    @top = top
    setNoMatchText("Must be a date in format 'dd/MM/yyyy'")
  end

  # Reimplement the validate method to check the validity of
  # input as an existing date.
  #
  def validate(input, pos)
    state = super(input, pos)
    text = input
  
    if state == Wt::WValidator::Valid && !text.empty?
      if regExp =~ text
        begin
          d = Date.new($3.to_i, $2.to_i, $1.to_i)
        rescue
          return Wt::WValidator::Invalid
        end
        if d >= @bottom && d <= @top
          return Wt::WValidator::Valid
        else
          return Wt::WValidator::Invalid
        end
      else
        return Wt::WValidator::Invalid
      end
    else
      return state
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
