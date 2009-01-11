if ENV['WT_ENV'] == 'production'
  require 'wtfcgi'
elsif ENV['WT_ENV'] == 'development'
  require 'wthttp'
elsif ENV['WT_ENV'] == 'test'
  require 'wthttp'
else
  require 'wthttp'
end
