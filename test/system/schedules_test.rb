require "application_system_test_case"

class SchedulesTest < ApplicationSystemTestCase
  test "visit the schedules page" do
    """
    log in as blank user and navigate to the schedules page
    Expected result:
      - See the schedules page
      - A list with active schedules saying there are no active schedules
      - A list with inactive schedules saying there are no inactive schedules
      - A button to create a new schedule
    """

    login_as_blank
    page.find(".navbar-gear").click
    click_on "Schedules"

    assert_selector 'h2', text: 'Schedules'
    assert_selector 'h3', text: 'Active Schedules'
    assert_selector 'h3', text: 'Inactive Schedules'

    assert_selector '#active-schedules ul', text: I18n.t('schedules.no_active_schedules')
    assert_selector '#inactive-schedules ul', text: I18n.t('schedules.no_inactive_schedules')

    assert_selector 'button#new-schedule-button', text: "New Schedule"
  end

  test "open and close schedule form" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    # check if the menu is visible
    assert_selector '#scheduleform', visible: :visible
    assert_selector '#scheduleform h5', text: 'New Schedule'

    # close the menu
    page.find("#scheduleform button.close").click

    # check if menu is hidden
    assert_selector '#scheduleform', visible: :hidden
  end

  test "default fields" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    assert_selector '#scheduleform #type-simple.active', text: 'Simple'
    assert_selector '#scheduleform #schedule_name'
    expect(page).to have_select('#scheduleform #schedule_schedule', selected: 'Monthly')
  end

  test "change simple period" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    
  end

  test "change weekday period" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    
  end

  test "advanced options" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    
  end
end