require 'test_helper'

class ProjectLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    get root_path
    assert_template 'welcome/index'
    assert_select 'a[href=?]', root_path, count: 1
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', articles_path
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', signup_path

    get signup_path
    assert_select 'title', full_title('Регистрация')

    get login_path
    assert_select 'title', full_title('Вход')
  end
end
