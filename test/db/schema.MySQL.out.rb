# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "companies", :force => true do |t|
    t.string  "name"
    t.integer "owner_id"
  end

  create_table "users", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "address"
    t.integer "age"
  end

  create_view "v_user_companies", :force => true do |v|
    v.use_raw_sql 'CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_user_companies` AS select `users`.`email` AS `email`,`companies`.`name` AS `company_name` from (`users` left join `companies` on((`users`.`id` = `companies`.`owner_id`)))'
  end

end
