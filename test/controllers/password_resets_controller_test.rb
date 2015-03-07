require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

  test 'password_resets routes' do
    assert_routing({ path: '/password_resets/new', method: :get },
                   { controller: 'password_resets', action: 'new' })
    assert_routing({ path: '/password_resets', method: :post },
                   { controller: 'password_resets', action: 'create' })
    assert_routing({ path: '/password_resets/1/edit', method: :get },
                   { controller: 'password_resets', action: 'edit', id: '1' })
    assert_routing({ path: '/password_resets/1', method: :patch },
                   { controller: 'password_resets', action: 'update', id: '1' })
    assert_routing({ path: '/password_resets/1', method: :put },
                   { controller: 'password_resets', action: 'update', id: '1' })
  end
end