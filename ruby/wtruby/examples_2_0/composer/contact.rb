class Contact
  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  def formatted
    return '"' + name + '" <' + email + ">";
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
