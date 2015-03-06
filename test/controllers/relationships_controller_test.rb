require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  test 'creating relationship should require logged-in user' do
    assert_no_difference 'Relationship.count' do
      post :create
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'destroying relationship should require logged-in user' do
    assert_no_difference 'Relationship.count' do
      delete :destroy, id: relationships(:one)
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end
end
