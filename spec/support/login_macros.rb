module LoginMacros
  def visit_page(page_name, page_user)
    Capybara.page.visit(page_name)

    validate_page page_user
  end

  def validate_page(page_user)
    logged_in_user = Capybara.page.all("#login-state")

    if logged_in_user && logged_in_user.length > 0 && " #{logged_in_user[0]["class"]} " =~ / not-logged-in /
      Capybara.page.fill_in("user_password", with: page_user.password)
      Capybara.page.fill_in("user_email", with: page_user.email)
      Capybara.page.click_button "Log in"
    end
  end
end