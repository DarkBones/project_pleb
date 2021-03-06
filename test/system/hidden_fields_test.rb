require 'application_system_test_case'

class HiddenFieldsTest < ApplicationSystemTestCase

  test 'transaction menu' do
    login_user(users(:upcoming_transactions_run), 'SomePassword123^!')

    click_on I18n.t('views.layouts.left_menu.new_transaction')
    sleep 1
    
    assert_selector '#active_account_field', visible: :hidden
    assert_selector '#edit_transaction__category_id_', visible: :hidden
    assert_selector '#timezone_input', visible: :hidden
  end

  test 'add transactions to schedule' do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find('#account_0').click

    page.find('#select_transaction_5jGb4q5OIy2l').click

    page.find('#mass_assign_to_schedule').click

    assert_selector '#schedules_transaction_transactions', visible: :hidden
  end

  test 'filter form' do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find('#account_0').click
    page.find('#advanced_search_toggle').click
    sleep 1
    assert_selector '#filterrific_category_id_filter', visible: :hidden
  end

  test 'sign up form' do
    visit root_path
    all('a', :text => I18n.t('views.devise.shared.buttons.sign_up.text'))[0].click
    assert_selector '#timezone_input', visible: :hidden
  end

  test 'sign in form' do
    visit root_path
    all('a', :text => I18n.t('views.devise.shared.buttons.sign_in.text'))[0].click
    assert_selector '#timezone_input', visible: :hidden
  end

  test 'schedule form' do
    login_as_blank
    visit '/schedules'
    click_on I18n.t('views.schedules.index.new')

    assert_selector '#timezone_input', visible: :hidden
    assert_selector '#schedule_dates_picked', visible: :hidden
    assert_selector '#schedule_dates_picked_exclude', visible: :hidden
  end
end
