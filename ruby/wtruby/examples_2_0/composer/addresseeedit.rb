#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
#*
#  composerexample
#
# An edit field for an email addressee.
#
# This widget is part of the %Wt composer example. 
#
class AddresseeEdit < Wt::WTextArea

  def initialize(label, parent, labelParent)
    super(parent)
    @label = Label.new(label, labelParent)
  
    setRows(3)
    setColumns(55)
    resize(Wt::WLength.new(99, Wt::WLength::Percentage), Wt::WLength.new)
  
    setInline(false) # for IE to position the suggestions well
  end

  def addressees=(contacts)
    text = contacts.map {|contact| contact.formatted}.join(", ")
    setText(text)
  end

  def parse(contacts)
    t = text()
    t.split(',').each do |addressee|
      addressee.lstrip!
      addressee.rstrip!
      if addressee =~ /(.*) ([^ ]*)$/
        name = $1
        email = $2
        name.sub!(/^"(.*)"$/, '\1')
        email.sub!(/^<(.*)>$/, '\1')
        if !email.empty?
          contacts.push(Contact.new(name, email))
        end
      elsif !addressee.empty?
        contacts.push(Contact.new("", addressee))
      end
    end
    return true
  end

  def addressees 
    result = []
    parse(result)
  
    return result
  end

  def hidden=(how)
    super(how)
    @label.hidden = how
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
