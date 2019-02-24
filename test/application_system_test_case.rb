require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def login_user(user, password)
    visit root_path

    click_on "Sign in"

    fill_in "Email", with: user.email
    fill_in "Password", with: password

    page.execute_script("$('input[name=\"commit\"]').click()")
  end

  def login_as_blank
    user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)
  end

  def logout
    sleep 2
    page.find(".navbar-gear").click
    click_on "Sign out"
  end
end
