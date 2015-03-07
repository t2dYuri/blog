require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test 'sessions routes' do
    assert_routing({ path: '/login', method: :get },
                   { controller: 'sessions', action: 'new' })
    assert_routing({ path: '/login', method: :post },
                   { controller: 'sessions', action: 'create' })
    assert_routing({ path: '/logout', method: :delete },
                   { controller: 'sessions', action: 'destroy' })
  end
end
