require "test_helper"
require 'active_record/schema_dumper'

class SchemaDumperTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.connection.execute('drop view if exists v_user_companies')
  end
  
  def teardown
    ActiveRecord::Base.connection.execute('drop view if exists v_user_companies')
  end
  
  def test_view
    create_user_company_view
    stream = StringIO.new
    dumper = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.rewind
 #   puts "#{stream.readlines.join}"
    expected_schema= 'create_view "v_user_companies", :force => true do |v|'

    assert_match expected_schema, stream.readlines.join
  end
  
  def test_dump_and_load
    create_user_company_view
    schema_file = File.dirname(__FILE__) + "/db/schema.#{ActiveRecord::Base.connection.adapter_name}.out.rb"
    assert_nothing_raised do
      File.open(schema_file, "w+") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
    
    ActiveRecord::Base.connection.drop_view(:v_user_companies)
    
    assert_nothing_raised do
      load(schema_file)
    end
  end

end
