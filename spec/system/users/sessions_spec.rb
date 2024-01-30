# frozen_string_literal: true

require "system_helper"

RSpec.describe "Signing in" do
  fixtures :publishers, :users

  before do
    solutions_territoire.update(allow_2fa_via_email: true)
    marc.update(password: "monkey-business", otp_method: "2fa", otp_secret: User.generate_otp_secret)
    elise.update(password: "monkey-business", otp_method: "email", otp_secret: User.generate_otp_secret)
  end

  let(:solutions_territoire) { publishers(:solutions_territoire) }
  let(:marc)                 { users(:marc) }
  let(:elise)                { users(:elise) }

  it "logs in" do
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: marc.email
    fill_in "Mot de passe", with: marc.password
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
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: elise.email
    fill_in "Mot de passe", with: elise.password
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
      .to(elise.email)
      .with_subject("Connexion à Passerelle")
      .with_body(include(elise.current_otp))

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

  it "rejects login attempt with unknown email" do
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: "leonard@solutions-territoire.fr"
    fill_in "Mot de passe", with: "monkey-business"
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
    fill_in "Adresse mail", with: marc.email
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
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: marc.email
    fill_in "Mot de passe", with: marc.password
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
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: marc.email
    fill_in "Mot de passe", with: marc.password
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
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_no_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Adresse mail")
    expect(page).to have_field("Mot de passe")

    # Fill the login form
    #
    fill_in "Adresse mail", with: elise.email
    fill_in "Mot de passe", with: elise.password
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

  it "locks an user and send instructions after a maximum number of login attempts" do
    visit new_user_session_path

    3.times do
      # Fill the login form
      #
      fill_in "Adresse mail", with: marc.email
      fill_in "Mot de passe", with: "hackme"
      click_on "Connexion"

      # The browser should stay on the same page
      # and refresh the login form
      #
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_field("Adresse mail", with: "mdebomy@solutions-territoire.fr")
      expect(page).to have_field("Mot de passe", with: "")
    end

    # It should have locked the user
    # And send instructions to him to unlock its account
    #
    expect { marc.reload }.to change(marc, :locked_at)

    perform_enqueued_jobs
    expect(Users::Mailer).to have_sent_email
      .to(marc.email)
      .with_subject("Verrouillage de votre compte Passerelle")
  end

  it "locks an user and send instructions after a maximum number of 2FA attempts" do
    visit new_user_session_path

    # Fill the login form
    #
    fill_in "Adresse mail", with: marc.email
    fill_in "Mot de passe", with: marc.password
    click_on "Connexion"

    # The browser should stay on the same page
    # The form should now require an OTP code
    #
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_selector("h1", text: "Authentification en 2 facteurs")
    expect(page).to have_field("Code de vérification")

    3.times do
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
    end

    # It should have locked the user
    # And send instructions to him to unlock its account
    #
    expect { marc.reload }.to change(marc, :locked_at)

    perform_enqueued_jobs
    expect(Users::Mailer).to have_sent_email
      .to(marc.email)
      .with_subject("Verrouillage de votre compte Passerelle")
  end
end
