module LoginMacros
  def visit_page(page_name, page_user)
    Capybara.page.visit(page_name)

    validate_page page_user
  end

  def validate_page(page_user)
    inputs = Capybara.page.all("input")

    # I don't override the sign in view and i18n it.
    # In the future when I do i18n, I need to update the test.
    if (inputs && inputs.length > 0 && inputs[inputs.length - 1].value == "Sign in")
      Capybara.page.fill_in("user_password", with: page_user.password)
      Capybara.page.fill_in("user_email", with: page_user.email)
      Capybara.page.click_button "Sign in"
    end
  end
end