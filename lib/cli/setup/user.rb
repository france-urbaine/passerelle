# frozen_string_literal: true

require_relative "../base"
require_relative "../../../config/environment"

module CLI
  class Setup
    class User < Base
      def call
        say "Setup user"

        email, first_name, last_name = prompt_user_data
        user = create_user(email, first_name, last_name)

        return if user.confirmed?

        url = Rails.application.routes.url_helpers.user_registration_url(
          host:  "http://localhost:3000",
          token: user.confirmation_token
        )

        say <<~MESSAGE
          To complete your registration process:

          1. Start a server with the command:

              bin/dev

          2. Then, follow the link below:

              #{url}
          \x5
        MESSAGE
      end

      def prompt_user_data
        email, first_name, last_name = user_data_from_git

        if email.present?
          say "To create a new user with these data, press [Enter]."
          say "Otherwise, please fill annoter email:"

          answer = ask

          if answer.blank?
            email      = answer
            first_name = nil
            last_name  = nil
          end
        end

        loop do
          break if email.present?

          say "Please enter your email:"
          email = ask
        end

        if first_name.blank?
          say "Please enter your first name (or press [Enter] to generate a random value):"
          first_name = ask.presence || Faker::Name.first_name
        end

        if last_name.blank?
          say "Please enter your last name (or press [Enter] to generate a random value):"
          last_name = ask.presence || Faker::Name.last_name
        end

        [email, first_name, last_name]
      end

      def user_data_from_git
        email = `git config --get user.email`.strip
        name  = `git config --get user.name`.strip.split(" ", 2)

        return if email.blank?

        first_name = name[0]
        last_name  = name[1]

        say "We found this user data in your git config:"
        say ""
        say "    email:      #{email}"
        say "    first_name: #{first_name}" if first_name.present?
        say "    last_name:  #{last_name}"  if last_name.present?
        say ""

        [email, first_name, last_name]
      end

      def create_user(email, first_name, last_name)
        user = ::User.find_by(email: email)

        if user&.confirmed?
          say ""
          say "This user already exists and is ready to log in!"
        elsif user
          say ""
          say "This user already exists."
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

          say ""
          say "Your user has been created"
        end

        user
      end
    end
  end
end
