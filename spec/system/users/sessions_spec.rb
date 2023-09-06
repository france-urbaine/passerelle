# frozen_string_literal: true

require "system_helper"

RSpec.describe "Signing in" do
  fixtures :publishers, :users

  let(:marc)                 { users(:marc) }
  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }

  it "log in an user" do
    # Setup user to generate OTP through an app
    #
    marc.update(password: "fiscahub/fiscahub", otp_method: "2fa", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    fill_in "Adresse mail", with: "mdebomy@fiscalite-territoire.fr"
    fill_in "Mot de passe", with: "fiscahub/fiscahub"

    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    fill_in "Code de vérification", with: marc.current_otp

    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Marc Debomy", visible: :all)
  end

  it "log in an user with an OTP code received by email" do
    # Setup user to receive OTP code by email
    #
    fiscalite_territoire.update(allow_2fa_via_email: true)
    marc.update(password: "fiscahub/fiscahub", otp_method: "email", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@fiscalite-territoire.fr"
    fill_in "Mot de passe", with: "fiscahub/fiscahub"

    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    # It should have sent a code by email
    #
    perform_enqueued_jobs

    expect(Users::Mailer).to have_sent_email
      .to("mdebomy@fiscalite-territoire.fr")
      .with_subject("Connexion à FiscaHub")
      .with_body(include(marc.current_otp))

    fill_in "Code de vérification", with: marc.current_otp

    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Marc Debomy", visible: :all)
  end
end
