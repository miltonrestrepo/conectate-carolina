module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path(locale: 'en')
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin(email, password)
      visit new_user_session_path(locale: 'en')
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      # save_and_open_page
      click_button 'Sign in'
    end
  end
end
