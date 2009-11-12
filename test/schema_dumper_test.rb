require "test_helper"
require 'active_record/schema_dumper'

class SchemaDumperTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.connection.execute('drop view if exists v_user_company')
  end
  
  def teardown
    ActiveRecord::Base.connection.execute('drop view if exists v_user_company')
  end
  
  def test_view
    create_user_company_view
    stream = StringIO.new
    dumper = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.rewind
    
    expected_schema = "create_view \"v_user_company\" do |v|\n    v.select \"CREATE VIEW \\\"v_user_company\\\" AS SELECT * FROM \\\"users\\\"\"\n  end\n\nend\n"

    assert_match expected_schema, stream.read #File.open(File.dirname(__FILE__) + "/schema.#{$connection}.expected.rb", 'r').readlines, 
  end
  
  def test_dump_and_load
    create_user_company_view
    schema_file = File.dirname(__FILE__) + "/db/schema.#{ActiveRecord::Base.connection.adapter_name}.out.rb"
    assert_nothing_raised do
      File.open(schema_file, "w+") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
        
    assert_nothing_raised do
      load(schema_file)
    end
  end
  
  # def test_union
  #   Person.create(:first_name => 'Joe', :last_name => 'User', :ssn => '123456789')
  #   Person2.create(:first_name => 'Jane', :last_name => 'Doe', :ssn => '222334444')
  #   
  #   select_stmt = <<-HERE
  #     select first_name, last_name, ssn from people
  #     UNION
  #     select first_name, last_name, ssn from people2
  #   HERE
  #   
  #   ActiveRecord::Base.connection.create_view(:v_profile, select_stmt, :force => true) do |v|
  #     v.column :first_name
  #     v.column :last_name
  #     v.column :ssn
  #   end
  #   
  #   assert_dump_and_load_succeed
  # end
  # def test_symbol_ignore
  #   ActiveRecord::SchemaDumper.ignore_views << :v_people
  #   create_people_view
  #   assert_dump_and_load_succeed
  #   ActiveRecord::SchemaDumper.ignore_views.pop
  # end
  # def test_regex_ignore
  #   ActiveRecord::SchemaDumper.ignore_views << Regexp.new(/v_people/)
  #   create_people_view
  #   assert_dump_and_load_succeed
  #   ActiveRecord::SchemaDumper.ignore_views.pop
  # end
  # def test_non_allowed_object_raises_error
  #   create_people_view
  #   ActiveRecord::SchemaDumper.ignore_views << 0
  #   begin
  #     schema_file = File.dirname(__FILE__) + "/schema.#{$connection}.out.rb"
  #     File.open(schema_file, "w") do |file|
  #       assert_raise(StandardError) do
  #         ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
  #       end
  #     end
  #   ensure
  #     ActiveRecord::SchemaDumper.ignore_views.pop
  #   end
  # end
  # 
  # def test_logging_error
  #   ActiveRecord::SchemaDumper.ignore_views << 0
  #   old_logger = ActiveRecord::Base.logger
  #   
  #   begin
  #     mock_logger = flexmock('logger', :error => nil)
  #     mock_logger.should_receive(:error)
  #     ActiveRecord::Base.logger = mock_logger
  #     schema_file = File.dirname(__FILE__) + "/schema.#{$connection}.out.rb"
  #     File.open(schema_file, "w") do |file|
  #       ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
  #     end
  #   ensure
  #     ActiveRecord::SchemaDumper.ignore_views.pop
  #     ActiveRecord::Base.logger = old_logger
  #   end
  # end
  # 
  # def assert_dump_and_load_succeed
  #   schema_file = File.dirname(__FILE__) + "/schema.#{$connection}.out.rb"
  #   assert_nothing_raised do
  #     File.open(schema_file, "w") do |file|
  #       ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
  #     end
  #   end
  # 
  #   assert_nothing_raised do
  #     load(schema_file)
  #   end
  # end
end
