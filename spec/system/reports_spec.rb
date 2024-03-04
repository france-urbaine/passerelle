# frozen_string_literal: true

require "system_helper"

RSpec.describe "Reports" do
  fixtures :all

  context "when organization is a collectivity" do
    before { sign_in(users(:christelle)) }

    it "searches for reports using quick search input" do
      visit reports_path

      # All reports should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a simple string criterion
      #
      fill_in "Rechercher", with: "2024-01-0001-00001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a hash-like string criteria
      #
      fill_in "Rechercher", with: "paquet:2024-01-0001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with multiple hash-like string criteria
      #
      fill_in "Rechercher", with: "commune:bayonne type:(local pro)"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a mix of hash-like criteria and simple string criterion
      #
      fill_in "Rechercher", with: "état:(Signalement rejeté) bayonne"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })
    end
  end

  context "when organization is a DDFIP" do
    before { sign_in(users(:maxime)) }

    it "searches for reports using quick search input" do
      visit reports_path

      # All reports should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a simple string criterion
      #
      fill_in "Rechercher", with: "2024-01-0001-00001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a hash-like string criteria
      #
      fill_in "Rechercher", with: "paquet:2024-01-0001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with multiple hash-like string criteria
      #
      fill_in "Rechercher", with: "commune:bayonne type:(local pro)"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a mix of hash-like criteria and simple string criterion
      #
      fill_in "Rechercher", with: "état:(Signalement rejeté) bayonne"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })
    end

    it "updates the state of several reports" do
      # Create a bunch of reports to have several pages
      #
      ddfip        = ddfips(:pyrenees_atlantiques)
      collectivity = collectivities(:pays_basque)
      create_list(:report, 10, :transmitted_to_ddfip, collectivity:, ddfip:)
      create_list(:report, 5, :approved_by_ddfip, collectivity:, ddfip:)

      visit reports_path

      expect(page).to have_text("18 signalements | Page 1 sur 1")

      # Paginate reports by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("18 signalements | Page 1 sur 2")

      expect(page).to have_selector(:table_row, { "État" => "Nouveau signalement" }, count: 8)
      expect(page).to have_selector(:table_row, { "État" => "Signalement rejeté"  }, count: 1)
      expect(page).to have_selector(:table_row, { "État" => "Signalement assigné" }, count: 1)

      # Checkboxes should be present to select all reports
      #
      within :table do
        check nil, match: :first
      end

      # A message should diplay the number of selected users
      # A button to select all reports from all pages should be present
      # A button to accept all of them should be present
      #
      within ".datatable__selection", text: "10 signalements sélectionnés" do
        click_on "Sélectionner les 18 signalements des 2 pages"
      end

      within ".datatable__selection", text: "18 signalements sélectionnés" do
        click_on "Accepter"
      end

      # A modal dialog should appear
      #
      within "[role=dialog]", text: "Vous avez sélectionné 18 signalements" do |dialog|
        expect(dialog).to have_text("12 signalements seront acceptés")
        expect(dialog).to have_text("6 signalements déjà assignés ou traités seront ignorés")
        click_on "Continuer"
      end

      # The states of the reports should have changed
      #
      expect(page).to have_text("18 signalements | Page 1 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "Signalement accepté" }, count: 9)
      expect(page).to have_selector(:table_row, { "État" => "Signalement assigné" }, count: 1)

      # Moving on second page
      #
      click_on "Page suivante"

      expect(page).to have_text("18 signalements | Page 2 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "Signalement accepté" }, count: 3)
      expect(page).to have_selector(:table_row, { "État" => "Réponse positive" }, count: 5)
    end

    it "updates the state of reports matching search criteria" do
      # Create a bunch of reports to have several pages
      #
      ddfip        = ddfips(:pyrenees_atlantiques)
      collectivity = collectivities(:pays_basque)
      packages     = create_list(:package, 3, collectivity:, ddfip:)
      create_list(:report, 6, :transmitted_to_ddfip, collectivity:, ddfip:, package: packages[0])
      create_list(:report, 6, :transmitted_to_ddfip, collectivity:, ddfip:, package: packages[1])
      create_list(:report, 6, :approved_by_ddfip,    collectivity:, ddfip:, package: packages[2])

      visit reports_path

      # Fill the search form
      #
      fill_in "Rechercher", with: "paquet:(#{packages[1].reference}, #{packages[2].reference})"
      find("input[type=search]").send_keys :enter

      expect(page).to have_text("12 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "État" => "Nouveau signalement" }, count: 6)
      expect(page).to have_selector(:table_row, { "État" => "Réponse positive"    }, count: 6)

      # Paginate reports by 10
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("12 signalements | Page 1 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "Nouveau signalement" }, count: 6)
      expect(page).to have_selector(:table_row, { "État" => "Réponse positive"    }, count: 4)

      # Checkboxes should be present to select all reports
      #
      within :table do
        check nil, match: :first
      end

      # A message should diplay the number of selected users
      # A button to select all reports from all pages should be present
      # A button to accept all of them should be present
      #
      within ".datatable__selection", text: "10 signalements sélectionnés" do
        click_on "Sélectionner les 12 signalements des 2 pages"
      end

      within ".datatable__selection", text: "12 signalements sélectionnés" do
        click_on "Accepter"
      end

      # A modal dialog should appear
      #
      within "[role=dialog]", text: "Vous avez sélectionné 12 signalements" do |dialog|
        expect(dialog).to have_text("6 signalements seront acceptés")
        expect(dialog).to have_text("6 signalements déjà assignés ou traités seront ignorés")
        click_on "Continuer"
      end
    end
  end
end
