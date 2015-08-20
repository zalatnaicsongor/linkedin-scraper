module Linkedin
  class HTTPClientFactory

    def self.create
      Watir::Browser.new
    end

    def self.create_authencticated_browser(username, password)
      browser = Watir::Browser.new
      browser.goto "linkedin.com"
      browser.text_field(:id => 'session_key-login').set(username)
      browser.text_field(:id => 'session_password-login').set(password)
      browser.button(:id => 'signin').click
      raise CouldNotLogInException, 'Could not log in with the supplied username / password!' if browser.text_field(:id => 'session_key-login').exists?
      return browser
    end

    def self.create_authenticated_headless(username, password)
        agent = Mechanize.new 
        agent.get('https://www.linkedin.com') do |login_page|
          login_page.form_with(:id => 'login') do |form|
            username_field = form.field_with(:id => 'session_key-login')
            username_field.value = username
            password_field = form.field_with(:id => 'session_password-login')
            password_field.value = password
          end.submit
          agent.get('https://www.linkedin.com') do |loggedin_page|
            raise CouldNotLogInException, 'Could not log in with the supplied username / password!' if loggedin_page.form_with(:id => 'login') != nil
          end
        end
        return agent
    end
  end
end
