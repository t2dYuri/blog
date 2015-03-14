require "test_helper"

class CanSignupTest < Capybara::Rails::TestCase

  test "sanity" do
    visit root_path
    assert_content page, "BloGG"
    refute_content page, "Goobye All!"
  end

  test 'capybara test' do
    visit root_path

    click_on 'Регистрация'

    assert page.has_content?('Регистрация')
    assert_content page, 'Регистрация'
    assert_content 'Регистрация'

    assert_selector 'h4'
    # print page.html
  end
end
