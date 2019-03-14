require "application_system_test_case"

class ScheduleFormsTest < ApplicationSystemTestCase

=begin
  test "initial visible fields" do

    login_as_blank
    page.find(".navbar-gear").click
    click_on "Schedules"
    click_on "New Schedule"

    assert_selector "#scheduleform", visible: :visible
    assert_selector "#scheduleform #scheduleform_type", visible: :visible
    assert_selector "#scheduleform #scheduleform_schedule", visible: :visible

    assert_selector "#scheduleform .schedule-advanced", visible: :hidden
    assert_selector "#scheduleform #scheduleform_days", visible: :hidden
    assert_selector "#scheduleform #scheduleform_days2", visible: :hidden
    assert_selector "#scheduleform #daypicker", visible: :hidden
    assert_selector "#scheduleform #weekday", visible: :hidden
    assert_selector "#scheduleform #end-date", visible: :hidden
    assert_selector "#scheduleform #weekday-exclude", visible: :hidden
    assert_selector "#scheduleform #daypicker-exclude", visible: :hidden
    assert_selector "#scheduleform #exclusion_met1", visible: :hidden
    assert_selector "#scheduleform #exclusion_met2", visible: :hidden

  end
=end

  test "show hide fields" do

    form_fields = ["#scheduleform",
      "#scheduleform #schedule_type",
      "#scheduleform #schedule_schedule",
      "#scheduleform .schedule-advanced",
      "#scheduleform #schedule_days",
      "#scheduleform #schedule_days2",
      "#scheduleform #daypicker",
      "#scheduleform #weekday",
      "#scheduleform #end-date",
      "#scheduleform #weekday-exclude",
      "#scheduleform #daypicker-exclude",
      "#scheduleform #exclusion_met1",
      "#scheduleform #exclusion_met2"
    ]

    login_as_blank
    page.find(".navbar-gear").click
    click_on "Schedules"
    click_on "New Schedule"
    

    ["advanced", "simple"].each do |type|

      page.find("#scheduleform #type-#{type}").click

      ["Daily", "Weekly", "Monthly", "Annually"].each do |schedule|
        field_mask = 0b0
        field_mask = add_field_mask("#scheduleform", field_mask, form_fields)
        field_mask = add_field_mask("#scheduleform #scheduleform_type", field_mask, form_fields)
        field_mask = add_field_mask("#scheduleform #scheduleform_schedule", field_mask, form_fields)

        select schedule, from: "Schedule"

        if type == "advanced"

          if schedule == "Weekly"
            field_mask = add_field_mask("#scheduleform #weekday", field_mask, form_fields)
            form_fields_bitmask(field_mask, form_fields)

            click_on "show advanced options"
            field_mask = add_field_mask("#scheduleform #end-date", field_mask, form_fields)
            form_fields_bitmask(field_mask, form_fields)
          elsif schedule == "Monthly"
            field_mask = add_field_mask("#scheduleform #scheduleform_days", field_mask, form_fields)

            ["every fourth", "every third", "every second", "every last", "every first", "specific dates"].each do |days|
              if days == "specific dates"
                field_mask = add_field_mask("#scheduleform #daypicker", field_mask, form_fields)
                
              end
            end
          end

        end

      end

    end

  end

  def add_field_mask(field, field_mask, form_fields)
    return field_mask | (1 << form_fields.index(field).to_i)
  end

  def form_fields_bitmask(bitmask, form_fields)
    puts bitmask.to_s(2).reverse
    bitmask = bitmask.to_s(2).reverse.split("")
    form_fields.each_with_index do |ff, ind|
      if bitmask[ind] == "1"
        assert_selector form_fields[ind].to_s, visible: :visible
      else
        #assert_selector form_fields[ind], visible: :hidden
      end
    end
  end
end