require 'test_helper'

class ViewModelTest < Test::Unit::TestCase
  
  def setup
    create_user_company_view
    
    @elad = User.create!(:name => 'Elad', :email => 'elad@koko.com')
    @noob = User.create!(:name => 'Noob', :email => 'noob@microsoft.com')
    
    @msft = Company.create!(:name => 'Microsoft')
    @nautilus = Company.create!(:name => 'Nautilus6')
    
    @msft.user = @noob
    @nautilus.user = @elad
  end
  
  def teardown
    User.delete_all
    Company.delete_all
  end
  
  def test_view_model_populated
    assert VUserCompany.count > 0
  end
  
  def test_right_company_name_returned
    @elad_company = VUserCompany.find(:first, :conditions => {:email => 'elad@koko.com'})
    assert 'Nautilus6', @elad_company.company_name
  end
  
  def test_prevent_changes_by_default
    assert_raises ActiveRecord::ReadOnlyRecord do
      VUserCompany.create(:email =>'cannot@creatme.com')
    end
    
    assert_raises ActiveRecord::StatementInvalid do
      VUserCompany.destroy_all
    end
    
  end
end
