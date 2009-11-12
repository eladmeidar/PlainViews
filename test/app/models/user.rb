class User < ActiveRecord::Base
  has_one :company, :foreign_key => 'owner_id'
end