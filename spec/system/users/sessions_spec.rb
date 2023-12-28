# frozen_string_literal: true

require "system_helper"

RSpec.describe "Signing in" do
  fixtures :publishers, :users

  let(:solutions_territoire) { publishers(:solutions_territoire) }
  let(:marc) { users(:marc) }
  let(:elise) { users(:elise) }

  it "logs in" do
    # Setup user credentials
    #
    marc.update(password: "passerelle/passerelle", otp_method: "2fa", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    # Fill the 2FA form
    #
    fill_in "Code de vérification", with: marc.current_otp
    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Marc Debomy", visible: :all)
  end

  it "logs in with an OTP code received by email" do
    # Setup user credentials to receive OTP code by email
    #
    solutions_territoire.update(allow_2fa_via_email: true)
    marc.update(password: "passerelle/passerelle", otp_method: "email", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
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
      .to("mdebomy@solutions-territoire.fr")
      .with_subject("Connexion à Passerelle")
      .with_body(include(marc.current_otp))

    # Fill the 2FA form
    #
    fill_in "Code de vérification", with: marc.current_otp
    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Marc Debomy", visible: :all)
  end

  it "rejects login attempt with unknown email" do
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "leonard@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
    click_on "Connexion"

    # The browser should stay on the same page
    # and refresh the login form
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_field("Adresse mail", with: "")
    expect(page).to have_field("Mot de passe", with: "")
    # expect(page).to have_selector("[role=log]", text: "Email et/ou mot de passe incorrect(s).")
  end

  it "rejects login attempt with invalid password" do
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@solutions-territoire.fr"
    fill_in "Mot de passe", with: "hackme"
    click_on "Connexion"

    # The browser should stay on the same page
    # and refresh the login form
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_field("Adresse mail", with: "mdebomy@solutions-territoire.fr")
    expect(page).to have_field("Mot de passe", with: "")

    # expect(page).to have_selector("[role=log]", text: "Email et/ou mot de passe incorrect(s).")
  end

  it "rejects OTP attempt" do
    # Setup user credentials
    #
    marc.update(password: "passerelle/passerelle", otp_method: "2fa", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    # Fill the 2FA form
    #
    fill_in "Code de vérification", with: "123456"
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should still require an OTP code
    # An error message is displayed
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")
    expect(page).to have_selector(".form-block__errors", text: "Code incorrect")

    # Fill the 2FA form
    #
    fill_in "Code de vérification", with: marc.current_otp
    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Marc Debomy", visible: :all)
  end

  it "allows to interrupt login process at OTP step, and then logs in with another user" do
    # Setup users credentials
    #
    marc.update(password: "passerelle/passerelle", otp_method: "2fa", otp_secret: User.generate_otp_secret)
    elise.update(password: "passerelle/passerelle", otp_method: "2fa", otp_secret: User.generate_otp_secret)

    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "mdebomy@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    # Go back to login form
    #
    click_on "Retour au formulaire de connexion"

    # The browser should stay on the same page
    # but the login form should be back
    #
    expect(page).to     have_current_path(new_user_session_path)
    expect(page).not_to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to     have_field("Adresse mail")
    expect(page).to     have_field("Mot de passe")

    # Fill the login form
    #
    fill_in "Adresse mail", with: "elacroix@solutions-territoire.fr"
    fill_in "Mot de passe", with: "passerelle/passerelle"
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    # Fill the 2FA form
    #
    fill_in "Code de vérification", with: elise.current_otp
    click_on "Connexion"

    # The browser should log in & redirect to the dashboard
    #
    expect(page).to have_current_path("/")
    expect(page).to have_selector("h1", text: "Tableau de bord")
    expect(page).to have_selector(".navbar__user-text", text: "Elise Lacroix", visible: :all)
  end
end
