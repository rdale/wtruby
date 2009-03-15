class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "user", :string, :limit => 50
      t.column "pass", :string, :limit => 50
      t.column "numgames", :integer
      t.column "score", :integer
      t.column "lastseen", :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
