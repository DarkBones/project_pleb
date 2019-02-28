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
    assert_selector '#transactionform', visible: :hidden
  end

  test "default fields" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    assert_selector ("#scheduleform #type-simple"), text: "Simple"
    assert_selector ("#scheduleform #type-advanced"), text: "Advanced"

    assert_selector '#scheduleform input#schedule_name', visible: :visible
    assert_selector '#scheduleform select#schedule_period', visible: :visible
    assert_selector '#scheduleform input#schedule_period_numeric', visible: :visible
    assert_selector '#scheduleform input#schedule_start_date', visible: :visible
    assert_selector '#scheduleform #weekday', visible: :hidden

    assert_selector ("#scheduleform p#period"), text: "Days"
  end

  test "change simple period" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    select "Months", from: "Period"
    assert_selector ("#scheduleform p#period"), text: "Months"

    select "Years", from: "Period"
    assert_selector ("#scheduleform p#period"), text: "Years"

    select "Days", from: "Period"
    assert_selector ("#scheduleform p#period"), text: "Days"
  end

  test "change weekday period" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    select "Weekday", from: "Period"
    assert_selector '#scheduleform #simple-period', visible: :hidden
    assert_selector '#scheduleform #weekday', visible: :visible

    select "Days", from: "Period"
    assert_selector '#scheduleform #simple-period', visible: :visible
    assert_selector '#scheduleform #weekday', visible: :hidden
  end
end
