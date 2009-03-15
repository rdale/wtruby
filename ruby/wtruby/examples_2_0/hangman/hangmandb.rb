require 'date'
require 'active_record.rb'
require 'digest/md5'

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))

class User < ActiveRecord::Base
end

module HangmanDb

  # this function returns false if user existed, true if user inserted
  # It guarantees atomic userExists() checking and adding it if the user
  # did not yet exits.
  def HangmanDb.addUser(user, password)
    begin
      u = User.new
      u.user = user
      u.pass = Digest::MD5.hexdigest(password)
      u.numgames = 0
      u.score = 0
      u.lastseen = DateTime.now
      u.save
    rescue
      return false
    end
    return true
  end

  # This function returns true when the credentials are found in the
  # database, otherwise false
  def HangmanDb.validLogin(user, pass)
    u = User.find(:first, :conditions => ['user = ? and pass = ?', user, Digest::MD5.hexdigest(pass)])
    return u.nil? ? false : true
  end

  # Increments the number of games played, and adds delta to the score
  # Returns the score structure for the given user
  def HangmanDb.addToScore(user, delta)
    u = User.find(:first, :conditions => ['user = ?', user])
    u.score += delta
    u.numgames += 1
    u.lastseen = DateTime.now
    u.save
    return u
  end

  # Returns the top n highest scoring users
  def HangmanDb.getHighScores(top)
    users = User.find(:all, :limit => top, :order => "score")
  end

  def HangmanDb.getUserPosition(user)
    users = User.find(:all, :order => "score")
    users.each_with_index do |u, i|
      if u.user == user
        return [u, i + 1]
      end
    end
  end

end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
