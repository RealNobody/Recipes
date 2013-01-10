module LoginMacros
  def visit_page(page_name, page_user)
    page.visit(page_name)

    inputs = page.all("input")

    # I don't override the sign in view and i18n it.
    # In the future when I do i18n, I need to update the test.
    if (inputs[inputs.length - 1].value == "Sign in")
      page.fill_in("user_password", with: page_user.password)
      page.fill_in("user_email", with: page_user.email)
      page.click_button "Sign in"
    end
  end
end