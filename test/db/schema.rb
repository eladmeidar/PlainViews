ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.string :address
    t.integer :age
  end
  
  create_table :companies, :force => true do |t|
    t.string :name
    t.integer :owner_id
  end
end