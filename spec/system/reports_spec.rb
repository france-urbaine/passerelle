# frozen_string_literal: true

require "system_helper"

RSpec.describe "Reports" do
  fixtures :all

  context "when organization is a collectivity" do
    before { sign_in(users(:christelle)) }

    it "visits index & report pages" do
      report = reports(:local_habitation_1020660947) # rubocop:disable Naming/VariableNumber

      visit reports_path

      # A table of all reports should be present
      #
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("4 signalements | Page 1 sur 1")
      expect(page).to have_link("Évaluation d'un local d'habitation", count: 3)
      expect(page).to have_link("Évaluation d'un local professionnel", count: 1)
      expect(page).to have_selector(:table_row, { "État" => "transmis",  "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "rejeté",    "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "accepté",   "Type de signalement" => "Évaluation d'un local professionnel", "Invariant" => "1020030272" })
      expect(page).to have_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      click_on "Évaluation d'un local d'habitation", match: :first

      # The browser should visit the report page
      #
      expect(page).to have_current_path(report_path(report))
      expect(page).to have_selector("h1", text: "Évaluation du local d'habitation 1020660947")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
    end

    it "searches for reports using quick search input" do
      visit reports_path

      # All reports should appear
      #
      expect(page).to have_text("4 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a simple string criterion
      #
      fill_in "Rechercher", with: "2024-01-0001-00001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_text("1 signalement | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with a hash-like string criteria
      #
      fill_in "Rechercher", with: "paquet:2024-01-0001"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criterion should appear
      #
      expect(page).to have_text("2 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

      # Fill the search form with multiple hash-like string criteria
      #
      fill_in "Rechercher", with: "commune:bayonne type:(local pro)"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_text("1 signalement | Page 1 sur 1")
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

    it "creates a report from the index page" do
      visit reports_path

      # A button should be present to add a new report
      #
      click_on "Ajouter un signalement"

      # A dialog box should appear with a form to fill
      #
      within "[role=dialog]", text: "Création d'un nouveau signalement" do |dialog|
        expect(dialog).to have_field("Type de formulaire")

        select "Évaluation d'un local professionnel", from: "Type de formulaire"

        click_on "Enregistrer"
      end

      # The browser should redirect to the new report form
      #
      expect(page).to have_current_path(report_path(Report.last))
      expect(page).to have_selector("h1", text: "Évaluation d'un local professionnel")
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector(".text-red-500", text: "Ce champs est requis", minimum: 9)

      # The dialog should be closed
      # No notification are displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_no_selector("[role=log]")
    end

    it "updates a report" do
      report = reports(:local_habitation_draft)

      visit report_path(report)

      # It should display some sections according to form type
      # It should display few informations
      # Some buttons should be present to edit each section of the report
      #
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector(".low-priority-icon")
      expect(page).to have_text("Date du constat 11 février 2024")
      expect(page).to have_link("Compléter", minimum: 4)

      within ".content__header", text: "Objet du signalement" do
        click_on "Compléter"
      end

      # A dialog box should appear with a form
      # The form should be filled with report data
      #
      within "[role=dialog]", text: "Définition de l'objet du signalement" do |dialog|
        expect(dialog).to have_checked_field("Tout sélectionner") #  (TODO verify indeterminate state)
        expect(dialog).to have_checked_field("Changement de consistance")
        expect(dialog).to have_unchecked_field("Changement d'affectation")
        expect(dialog).to have_unchecked_field("Exonération à tort")
        expect(dialog).to have_unchecked_field("Anomalie correctif d'ensemble")
        expect(dialog).to have_unchecked_field("Changement d'adresse")

        expect(dialog).to have_select("Priorité", selected: "Basse")
        expect(dialog).to have_field("Date du constat", with: "2024-02-11")

        check "Changement d'affectation"
        check "Changement d'adresse"

        select  "Moyenne", from: "Priorité"
        fill_in "Date du constat", with: "2024-02-09"

        click_on "Enregistrer"
      end

      # The browser should stay on the report page
      # Some new sections should appear
      # Informations should have been updated
      #
      expect(page).to have_current_path(report_path(report))
      expect(page).to have_selector("h1", text: "Évaluation d'un local d'habitation")

      expect(page).to have_no_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'affectation")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'adresse")

      expect(page).to have_selector(".medium-priority-icon")
      expect(page).to have_text("Date du constat 9 février 2024")

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

      # Click on button to update MAJIC data
      #
      within ".content__header", text: "Identification MAJIC" do
        click_on "Compléter"
      end

      # A dialog box should appear with a form
      # The form should be filled with report data
      #
      within "[role=dialog]", text: "Identification MAJIC" do
        fill_in "Invariant", with: "1020801922"

        click_on "Enregistrer"
      end

      # The title of the report should have been updated
      #
      expect(page).to have_current_path(report_path(report))
      expect(page).to have_selector("h1", text: "Évaluation du local d'habitation 1020801922")
    end

    it "discards a report from the report page & rollbacks" do
      report = reports(:local_habitation_draft)

      visit report_path(report)

      # A button should be present to remove the report
      #
      within ".breadcrumbs", text: "Évaluation d'un local d'habitation" do
        click_on "Supprimer"
      end

      # A confirmation dialog should appear
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce signalement ?" do
        click_on "Continuer"
      end

      # The browser should redirect to the index page
      # The report should not appear anymore
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("3 signalements | Page 1 sur 1")
      expect(page).to have_no_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The selection message should not appear anymore
      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Le signalement a été supprimé.")

      # The notification should include a button to cancel the last action
      #
      within "[role=log]", text: "Le signalement a été supprimé." do
        click_on "Annuler"
      end

      # The browser should stay on the index page
      # The report should be back again
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("4 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector("[role=log]", text: "Le signalement a été supprimé.")
      expect(page).to have_selector("[role=log]", text: "La suppression du signalement a été annulée.")
    end

    it "selects and discards one report from the index page & rollbacks" do
      visit reports_path

      expect(page).to have_text("4 signalements | Page 1 sur 1")

      # A button should be present to remove any report
      #
      within :table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" } do
        check
      end

      # A message should diplay the number of selected reports
      # with a button to remove them
      #
      within ".datatable__selection", text: "1 signalement sélectionné" do
        click_on "Supprimer"
      end

      # A confirmation dialog should appear
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer le signalement sélectionné ?" do
        click_on "Continuer"
      end

      # The browser should stay on index page
      # The selected report should not appear anymore
      # Other reports should remain
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("3 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "État" => "transmis",  "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "rejeté",    "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "accepté",   "Type de signalement" => "Évaluation d'un local professionnel", "Invariant" => "1020030272" })
      expect(page).to have_no_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The selection message should not appear anymore
      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")

      # The notification should include a button to cancel the last action
      #
      within "[role=log]", text: "Les signalements sélectionnés ont été supprimés." do
        click_on "Annuler"
      end

      # The browser should stay on index page
      # The remove report should be back again
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("4 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The selection message should not appear again
      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")
      expect(page).to have_selector("[role=log]", text: "La suppression des signalements sélectionnés a été annulée.")
    end

    it "selects and discards all reports from the current page on index page & rollbacks" do
      # Create a bunch of reports to have several pages
      # Create discarded reports to verify they are not rollbacked
      #
      collectivity = collectivities(:pays_basque)
      create_list(:report, 10, collectivity:)
      create_list(:report, 5, collectivity:)

      visit reports_path

      expect(page).to have_text("19 signalements | Page 1 sur 1")

      # Paginate reports by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("19 signalements | Page 1 sur 2")

      # Checkboxes should be present to select all reports
      #
      within :table do
        check nil, match: :first
      end

      # A message should diplay the number of selected reports
      # with a button to remove them
      #
      within ".datatable__selection", text: "10 signalements sélectionnés" do
        click_on "Supprimer"
      end

      # A confirmation dialog should appear
      # The transmitted reports are omitted
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 7 signalements sélectionnés ?" do
        click_on "Continuer"
      end

      # The browser should stay on index page
      # The selected reports should have been removed
      # The transmitted reports remain
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("12 signalements | Page 1 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "transmis",  "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "rejeté",    "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "accepté",   "Type de signalement" => "Évaluation d'un local professionnel", "Invariant" => "1020030272" })

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")

      # The notification should include a button to cancel the last action
      #
      within "[role=log]", text: "Les signalements sélectionnés ont été supprimés." do
        click_on "Annuler"
      end

      # The browser should stay on index page
      # All reports should be back again
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_text("19 signalements | Page 1 sur 2")

      # The selection message should not appears again
      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")
      expect(page).to have_selector("[role=log]", text: "La suppression des signalements sélectionnés a été annulée.")
    end

    it "selects and discards all reports through several pages on index page & rollbacks" do
      # Create a bunch of reports to have several pages
      # Create discarded reports to verify they are not rollbacked
      #
      collectivity = collectivities(:pays_basque)
      create_list(:report, 10, collectivity:)
      create_list(:report, 5, collectivity:)

      visit reports_path

      expect(page).to have_text("19 signalements | Page 1 sur 1")

      # Paginate reports by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("19 signalements | Page 1 sur 2")

      # Checkboxes should be present to select all reports
      #
      within :table do
        check nil, match: :first
      end

      # A message should diplay the number of selected reports
      # A link to select any reports from any page should be present
      # A link to remove all of them should be present
      #
      within ".datatable__selection", text: "10 signalements sélectionnés" do
        click_on "Sélectionner les 19 signalements des 2 pages"
      end

      within ".datatable__selection", text: "19 signalements sélectionnés" do
        click_on "Supprimer"
      end

      # A confirmation dialog should appear
      # The transmitted reports are omitted
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 16 signalements sélectionnés ?" do
        click_on "Continuer"
      end

      # The browser should stay on index page
      # The selected reports should have been removed
      # The transmitted reports remain
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("3 signalements | Page 1 sur 1")
      expect(page).to have_selector(:table_row, { "État" => "transmis",  "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "rejeté",    "Type de signalement" => "Évaluation d'un local d'habitation", "Invariant" => "1020660947" })
      expect(page).to have_selector(:table_row, { "État" => "accepté",   "Type de signalement" => "Évaluation d'un local professionnel", "Invariant" => "1020030272" })
      expect(page).to have_no_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")

      # The notification should include a button to cancel the last action
      #
      within "[role=log]", text: "Les signalements sélectionnés ont été supprimés." do
        click_on "Annuler"
      end

      # The browser should stay on index page
      # All reports should be back again
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("19 signalements | Page 1 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "incomplet", "Type de signalement" => "Évaluation d'un local d'habitation" })

      # The selection message should not appears again
      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=log]", text: "Les signalements sélectionnés ont été supprimés.")
      expect(page).to have_selector("[role=log]", text: "La suppression des signalements sélectionnés a été annulée.")
    end
  end

  context "when organization is a DDFIP" do
    before { sign_in(users(:maxime)) }

    it "visits index & report pages" do
      report = reports(:local_habitation_1020660947) # rubocop:disable Naming/VariableNumber

      visit reports_path

      # A table of all reports should be present
      #
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("3 signalements | Page 1 sur 1")
      expect(page).to have_link("Évaluation d'un local d'habitation", count: 2)
      expect(page).to have_link("Évaluation d'un local professionnel", count: 1)

      click_on "Évaluation d'un local d'habitation", match: :first

      # The browser should visit the report page
      #
      expect(page).to have_current_path(report_path(report))
      expect(page).to have_selector("h1", text: "Évaluation du local d'habitation 1020660947")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
    end

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

  context "when user is a DDFIP form admin" do
    before { sign_in(users(:remi)) }

    it "visits index & report pages" do
      report = reports(:local_habitation_1020660947) # rubocop:disable Naming/VariableNumber

      visit reports_path

      # A table of all reports should be present
      #
      expect(page).to have_selector("h1", text: "Signalements")
      expect(page).to have_text("2 signalements | Page 1 sur 1")
      expect(page).to have_link("Évaluation d'un local d'habitation", count: 2)

      click_on "Évaluation d'un local d'habitation", match: :first

      # The browser should visit the report page
      #
      expect(page).to have_current_path(report_path(report))
      expect(page).to have_selector("h1", text: "Évaluation du local d'habitation 1020660947")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(reports_path)
      expect(page).to have_selector("h1", text: "Signalements")
    end

    it "searches for reports using quick search input" do
      visit reports_path

      # All reports should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

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
      fill_in "Rechercher", with: "commune:bayonne type:(local habitation)"
      find("input[type=search]").send_keys :enter

      # Only reports matching the criteria should appear
      #
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
      expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
      expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0002-00001" })

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
      create_list(:report, 10, :transmitted_to_ddfip, collectivity:, ddfip:, form_type: "evaluation_local_habitation")
      create_list(:report, 5, :approved_by_ddfip, collectivity:, ddfip:, form_type: "evaluation_local_habitation")

      # Create reports that should not appear
      #
      create_list(:report, 5, :approved_by_ddfip, collectivity:, ddfip:, form_type: "evaluation_local_professionnel")

      visit reports_path

      expect(page).to have_text("17 signalements | Page 1 sur 1")

      # Paginate reports by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("17 signalements | Page 1 sur 2")

      expect(page).to have_selector(:table_row, { "État" => "Nouveau signalement" }, count: 9)
      expect(page).to have_selector(:table_row, { "État" => "Signalement rejeté"  }, count: 1)

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
        click_on "Sélectionner les 17 signalements des 2 pages"
      end

      within ".datatable__selection", text: "17 signalements sélectionnés" do
        click_on "Accepter"
      end

      # A modal dialog should appear
      #
      within "[role=dialog]", text: "Vous avez sélectionné 17 signalements" do |dialog|
        expect(dialog).to have_text("12 signalements seront acceptés")
        expect(dialog).to have_text("5 signalements déjà assignés ou traités seront ignorés")
        click_on "Continuer"
      end

      # The states of the reports should have changed
      #
      expect(page).to have_text("17 signalements | Page 1 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "Signalement accepté" }, count: 10)

      # Moving on second page
      #
      click_on "Page suivante"

      expect(page).to have_text("17 signalements | Page 2 sur 2")
      expect(page).to have_selector(:table_row, { "État" => "Signalement accepté" }, count: 2)
      expect(page).to have_selector(:table_row, { "État" => "Réponse positive" }, count: 5)
    end

    it "updates the state of reports matching search criteria" do
      # Create a bunch of reports to have several pages
      #
      ddfip        = ddfips(:pyrenees_atlantiques)
      collectivity = collectivities(:pays_basque)
      packages     = create_list(:package, 3, collectivity:, ddfip:)
      create_list(:report, 6, :transmitted_to_ddfip, collectivity:, ddfip:, package: packages[0], form_type: "evaluation_local_habitation")
      create_list(:report, 6, :transmitted_to_ddfip, collectivity:, ddfip:, package: packages[1], form_type: "evaluation_local_habitation")
      create_list(:report, 6, :approved_by_ddfip,    collectivity:, ddfip:, package: packages[2], form_type: "evaluation_local_habitation")

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
