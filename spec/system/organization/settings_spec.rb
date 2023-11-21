# frozen_string_literal: true

require "system_helper"

RSpec.describe "Settings of current organization" do
  fixtures :all

  context "when organization is a publisher" do
    before { sign_in(users(:marc)) }

    it "visits settings page to update identification data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with identification data
      #
      expect(page).to have_field("Nom de l'éditeur",          with: "Fiscalité & Territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "511022394")

      # Fill inputs with invalid data
      #
      fill_in "Nom de l'éditeur",          with: "  "
      fill_in "Numéro SIREN de l'éditeur", with: "848 905 758"

      within "#identification-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # No notification should be displayed
      # Some errors should be displayed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).not_to have_selector("[role=log]")
      expect(page).to     have_selector(".form-block__errors", text: "Un nom est requis")
      expect(page).to     have_selector(".form-block__errors", text: "Ce numéro SIREN n'est pas valide")

      # Fill inputs with valid data
      #
      fill_in "Nom de l'éditeur",          with: "Solutions & territoire"
      fill_in "Numéro SIREN de l'éditeur", with: "848905758"

      within "#identification-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
      expect(page).not_to have_selector(".form-block__errors")

      # Reload the page
      #
      visit current_path

      # Identification data should match what we filled
      #
      expect(page).to have_field("Nom de l'éditeur",          with: "Solutions & territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "848905758")
    end

    it "visits settings page to update contact data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with contact data
      #
      expect(page).to have_field("Prénom du contact",       with: "")
      expect(page).to have_field("Nom du contact",          with: "")
      expect(page).to have_field("Adresse mail de contact", with: "")
      expect(page).to have_field("Numéro de téléphone",     with: "")

      # Fill inputs with invalid data
      #
      fill_in "Numéro de téléphone", with: "+330 00 00 00 00"

      within "#contact-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # No notification should be displayed
      # Some errors should be displayed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).not_to have_selector("[role=log]")
      expect(page).to     have_selector(".form-block__errors", text: "Un numéro de téléphone valide est requis")

      # Fill inputs with valid data
      #
      fill_in "Prénom du contact",       with: "Paul"
      fill_in "Nom du contact",          with: "Lefebvre"
      fill_in "Adresse mail de contact", with: "contact@solutions-territoire.fr"
      fill_in "Numéro de téléphone",     with: "+33000000000"

      within "#contact-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
      expect(page).not_to have_selector(".form-block__errors")

      # Reload the page
      #
      visit current_path

      # Contact data should match what we filled
      #
      expect(page).to have_field("Prénom du contact",       with: "Paul")
      expect(page).to have_field("Nom du contact",          with: "Lefebvre")
      expect(page).to have_field("Adresse mail de contact", with: "contact@solutions-territoire.fr")
      expect(page).to have_field("Numéro de téléphone",     with: "+33000000000")
    end

    it "visits settings page to update security data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should match default security data
      #
      expect(page).to have_field("Nom de domaine", with: "")
      expect(page).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")

      # Fill first input
      #
      fill_in "Nom de domaine", with: "solutions-territoire.fr"

      within "#domain-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Check box to authorized 2FA method
      #
      check "Autoriser l'email comme méthode d'authentification en 2 étapes"

      within "#twofa-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Security data should match what we filled
      #
      expect(page).to have_field("Nom de domaine", with: "solutions-territoire.fr")
      expect(page).to have_checked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
    end
  end

  context "when organization is a collectivity" do
    before { sign_in(users(:christelle)) }

    it "visits settings page to update identification data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with identification data
      #
      expect(page).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de la collectivité", with: "200067106")
      expect(page).to have_select("Éditeur",                        selected: "Fiscalité & Territoire")

      # Fill inputs with valid data
      #
      fill_in "Nom de la collectivité",          with: "Agglomération du Pays Basque"
      fill_in "Numéro SIREN de la collectivité", with: "200067199"
      select "France Urbaine", from: "Éditeur"

      within "#identification-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Identification data should match what we filled
      #
      expect(page).to have_field("Nom de la collectivité",          with: "Agglomération du Pays Basque")
      expect(page).to have_field("Numéro SIREN de la collectivité", with: "200067199")
      expect(page).to have_select("Éditeur",                        selected: "France Urbaine")
    end

    it "visits settings page to update contact data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with contact data
      #
      expect(page).to have_field("Prénom du contact",       with: "")
      expect(page).to have_field("Nom du contact",          with: "")
      expect(page).to have_field("Adresse mail de contact", with: "")
      expect(page).to have_field("Numéro de téléphone",     with: "")

      # Fill inputs with valid data
      #
      fill_in "Prénom du contact",       with: "Paul"
      fill_in "Nom du contact",          with: "Lefebvre"
      fill_in "Adresse mail de contact", with: "contact@pays-basque.fr"
      fill_in "Numéro de téléphone",     with: "+33000000000"

      within "#contact-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Contact data should match what we filled
      #
      expect(page).to have_field("Prénom du contact",       with: "Paul")
      expect(page).to have_field("Nom du contact",          with: "Lefebvre")
      expect(page).to have_field("Adresse mail de contact", with: "contact@pays-basque.fr")
      expect(page).to have_field("Numéro de téléphone",     with: "+33000000000")
    end

    it "visits settings page to update security data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should match default security data
      #
      expect(page).to have_field("Nom de domaine", with: "")
      expect(page).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")

      # Fill first input
      #
      fill_in "Nom de domaine", with: "solutions-territoire.fr"

      within "#domain-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Check box to authorized 2FA method
      #
      check "Autoriser l'email comme méthode d'authentification en 2 étapes"

      within "#twofa-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Security data should match what we filled
      #
      expect(page).to have_field("Nom de domaine", with: "solutions-territoire.fr")
      expect(page).to have_checked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
    end
  end

  context "when organization is a DDFIP" do
    before { sign_in(users(:maxime)) }

    it "visits settings page to update identification data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with identification data
      #
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")

      # Fill inputs with valid data
      #
      fill_in "Nom de la DDFIP", with: "DRGIP du Sud-Aquitaine"

      within "#identification-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Identification data should match what we filled
      #
      expect(page).to have_field("Nom de la DDFIP", with: "DRGIP du Sud-Aquitaine")
    end

    it "visits settings page to update contact data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should be filled with contact data
      #
      expect(page).to have_field("Prénom du contact",       with: "")
      expect(page).to have_field("Nom du contact",          with: "")
      expect(page).to have_field("Adresse mail de contact", with: "")
      expect(page).to have_field("Numéro de téléphone",     with: "")

      # Fill inputs with valid data
      #
      fill_in "Prénom du contact",       with: "Paul"
      fill_in "Nom du contact",          with: "Lefebvre"
      fill_in "Adresse mail de contact", with: "contact@pays-basque.fr"
      fill_in "Numéro de téléphone",     with: "+33000000000"

      within "#contact-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to     have_current_path("/organisation/parametres")
      expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Contact data should match what we filled
      #
      expect(page).to have_field("Prénom du contact",       with: "Paul")
      expect(page).to have_field("Nom du contact",          with: "Lefebvre")
      expect(page).to have_field("Adresse mail de contact", with: "contact@pays-basque.fr")
      expect(page).to have_field("Numéro de téléphone",     with: "+33000000000")
    end

    it "visits settings page to update security data" do
      visit "/organisation/parametres"

      expect(page).to have_selector("h1", text: "Paramètres")

      # On the settings page, inputs should match default security data
      #
      expect(page).to have_field("Nom de domaine", with: "")
      expect(page).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")

      # Fill first input
      #
      fill_in "Nom de domaine", with: "solutions-territoire.fr"

      within "#domain-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Check box to authorized 2FA method
      #
      check "Autoriser l'email comme méthode d'authentification en 2 étapes"

      within "#twofa-settings-form" do
        click_on "Enregistrer"
      end

      # The browser should stay on the settings page
      # A notification should be displayed
      # Errors should be removed
      #
      expect(page).to have_current_path("/organisation/parametres")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Reload the page
      #
      visit current_path

      # Security data should match what we filled
      #
      expect(page).to have_field("Nom de domaine", with: "solutions-territoire.fr")
      expect(page).to have_checked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
    end
  end
end
