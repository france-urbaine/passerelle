# frozen_string_literal: true

require_relative "helpers"

git_email = `git config --get user.email`.strip
git_name  = `git config --get user.name`.strip.split(" ", 2)

if git_email.present?
  log "We found this user data in your git config:"
  log ""
  log "    email:      #{git_email}"
  log "    first_name: #{git_name[0]}" if git_name[0].present?
  log "    last_name:  #{git_name[1]}" if git_name[1].present?
  log ""
  log "To create a new user with these data, press [Enter]."
  log "Otherwise, please fill annoter email:"
  email = gets

  if email.blank?
    email      = git_email
    first_name = git_name[0]
    last_name  = git_name[1]
  end
else
  log "Please enter your email:"
  email = gets
end

if first_name.blank?
  log "Please enter your first name (or press enter to generate a random value):"
  first_name = gets
  first_name = Faker::Name.first_name if first_name.blank?
end

if last_name.blank?
  log "Please enter your last name (or press enter to generate a random value):"
  last_name = gets
  last_name = Faker::Name.last_name if last_name.blank?
end

user = User.find_by(email: email)

if user&.confirmed?
  log ""
  log "This user already exists and is ready to log in!"
elsif user
  log ""
  log "This user already exists."
else
  user = Publisher
    .create_or_find_by(siren: "511022394", name: "Solutions & Territoire", &:skip_uniqueness_validation!)
    .users.create!(
      email:              email,
      first_name:         first_name,
      last_name:          last_name,
      organization_admin: true,
      super_admin:        true,
      password:           Devise.friendly_token,
      &:skip_confirmation_notification!
    )

  log ""
  log "Your user has been created"
end

log ""
log "You can also configure your rails console by adding the following code to your `~/.irbrc`:"
log ""
log "    def my_email"

if git_email == email
  log "      @my_email ||= `git config --get user.email`.strip"
else
  log "      @my_email ||= \"#{email}\""
end

log "    end"
log ""
log "    def me"
log "      User.find_by(email: my_email)"
log "    end"
log ""
log "You will then be able to grab your user by using the `me` method:"
log ""
log "    $ rails c"
log "    #{RUBY_VERSION} :001 > me"
log "    => #<User first_name: \"#{first_name}\", last_name: \"#{last_name}\", email: \"#{email}\" [...]>"
log ""

unless user.confirmed?
  url = Rails.application.routes.url_helpers.user_registration_url(
    host:  "http://localhost:3000",
    token: user.confirmation_token
  )

  log ""
  log "-------------------------------------------------------------------------------------"
  log ""
  log "To complete your registration process:"
  log ""
  log "1. Start a server with the command:"
  log ""
  log "    bin/dev"
  log ""
  log "2. Then, follow the link below:"
  log ""
  log "    #{url}"
  log ""
  log "-------------------------------------------------------------------------------------"
end
