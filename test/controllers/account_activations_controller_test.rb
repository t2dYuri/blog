require 'test_helper'

class AccountActivationsControllerTest < ActionController::TestCase

  test 'account_activations routes' do
    assert_routing({ path: 'account_activations/1/edit', method: :get },
                   { controller: 'account_activations', action: 'edit', id: '1' })
  end
end
