require 'rubygems'
require 'active_record'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'

require 'lib/plain_view'
config = YAML::load(File.open('test/config/database.yml'))

db_adapter = ENV['DB']

# no db passed, try one of these fine config-free DBs before nuking everyone to hell.
db_adapter ||=
  begin
    require 'rubygems'
    require 'sqlite'
    'sqlite'
  rescue MissingSourceFile
    begin
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end
  end

if db_adapter.nil?
  raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
end

puts "Using #{db_adapter}"

# Connect
ActiveRecord::Base.establish_connection(config[db_adapter])

# Load schema 
load 'test/db/schema.rb'

# load models
Dir['test/app/models/**/*.rb'].each do |f| 
  require f
  puts "Loaded #{f}"
end


class Test::Unit::TestCase
  def create_user_company_view
    ActiveRecord::Base.connection.drop_view(:v_user_companies) rescue nil
    ActiveRecord::Base.connection.create_view :v_user_companies do |v|
      v.base_model :user
      v.select :select => 'users.email as email, companies.name as company_name', :joins => "LEFT JOIN companies on users.id = companies.owner_id"
    end
  end
end