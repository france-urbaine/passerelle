# frozen_string_literal: true

require "system_helper"

RSpec.describe "Office communes in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :ddfips, :offices, :office_communes, :users

  let(:ddfip64)      { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:pelh_bayonne) { offices(:pelh_bayonne) }
  let(:bayonne)      { communes(:bayonne) }

  before { sign_in(users(:marc)) }

  it "visits a comune page from the office page" do
    visit admin_office_path(pelp_bayonne)

    # A table of communes should be present
    #
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")
    expect(page).to have_selector(:table_row, { "Commune" => "64122" }, text: "Biarritz")

    click_on "Bayonne"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Bayonne")

    go_back

    # The browser should have redirect back to the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
  end

  it "paginate communes on the office page" do
    # Create enough communes to have several pages
    #
    pelp_bayonne.communes << create_list(:commune, 10, departement: pelp_bayonne.departement)

    visit admin_office_path(pelp_bayonne)

    expect(page).to have_text("12 communes | Page 1 sur 2")
    expect(page).to have_no_button("Options d'affichage")
  end

  it "manages communes from the office page" do
    visit admin_office_path(pelh_bayonne)

    # The communes list should be empty
    #
    expect(page).to have_text("Aucune commune assignée à ce guichet.")

    # A button should be present to manage communes
    #
    click_on "Gérer les communes"

    # A dialog box should appear with checkboxes
    # The checkboxes should allow to check communes and EPCIs of the DDFIP departement
    #
    within "[role=dialog]", text: "Gestion des communes asignées au guichet" do |dialog|
      expect(dialog).to have_unchecked_field("Tout le département")
      expect(dialog).to have_unchecked_field("CA du Pays Basque")
      expect(dialog).to have_unchecked_field("CA Pau Béarn Pyrénées")
      expect(dialog).to have_unchecked_field("Bayonne")
      expect(dialog).to have_unchecked_field("Biarritz")
      expect(dialog).to have_unchecked_field("Pau")

      check "CA du Pays Basque"

      # Checking an EPCI should:
      # - partialliy check the departement (TODO verify indeterminate state)
      # - check every communes of the EPCI
      #
      expect(dialog).to have_checked_field("Tout le département")
      expect(dialog).to have_checked_field("CA du Pays Basque")
      expect(dialog).to have_unchecked_field("CA Pau Béarn Pyrénées")
      expect(dialog).to have_checked_field("Bayonne")
      expect(dialog).to have_checked_field("Biarritz")
      expect(dialog).to have_unchecked_field("Pau")

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new communes should appear
    #
    expect(page).to have_current_path(admin_office_path(pelh_bayonne))
    expect(page).to have_selector("h1", text: "PELH de Bayonne")
    expect(page).to have_text("2 communes | Page 1 sur 1")
    expect(page).to have_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")
    expect(page).to have_selector(:table_row, { "Commune" => "64122" }, text: "Biarritz")

    # A notification should be displayed
    # The dialog should be closed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

    # Re-open the modal to add another EPCI
    #
    click_on "Gérer les communes"

    # A dialog box should appear with checkboxes
    # The checkboxes should be checked with assigned communes & EPCIs
    #
    within "[role=dialog]", text: "Gestion des communes asignées au guichet" do |dialog|
      expect(dialog).to have_checked_field("Tout le département")
      expect(dialog).to have_checked_field("CA du Pays Basque")
      expect(dialog).to have_unchecked_field("CA Pau Béarn Pyrénées")
      expect(dialog).to have_checked_field("Bayonne")
      expect(dialog).to have_checked_field("Biarritz")
      expect(dialog).to have_unchecked_field("Pau")

      check "CA Pau Béarn Pyrénées"

      expect(dialog).to have_checked_field("Tout le département")
      expect(dialog).to have_checked_field("CA du Pays Basque")
      expect(dialog).to have_checked_field("CA Pau Béarn Pyrénées")
      expect(dialog).to have_checked_field("Bayonne")
      expect(dialog).to have_checked_field("Biarritz")
      expect(dialog).to have_checked_field("Pau")

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new communes should appear
    #
    expect(page).to have_current_path(admin_office_path(pelh_bayonne))
    expect(page).to have_selector("h1", text: "PELH de Bayonne")
    expect(page).to have_text("3 communes | Page 1 sur 1")
    expect(page).to have_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")
    expect(page).to have_selector(:table_row, { "Commune" => "64122" }, text: "Biarritz")
    expect(page).to have_selector(:table_row, { "Commune" => "64445" }, text: "Pau")

    # A notification should be displayed
    # The dialog should be closed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

    # Re-open the modal to remove all communes
    #
    click_on "Gérer les communes"

    within "[role=dialog]", text: "Gestion des communes asignées au guichet" do |dialog|
      expect(dialog).to have_checked_field("Tout le département")
      expect(dialog).to have_checked_field("CA du Pays Basque")
      expect(dialog).to have_checked_field("CA Pau Béarn Pyrénées")
      expect(dialog).to have_checked_field("Bayonne")
      expect(dialog).to have_checked_field("Biarritz")
      expect(dialog).to have_checked_field("Pau")

      uncheck "Tout le département"
      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new communes should appear
    #
    expect(page).to have_current_path(admin_office_path(pelh_bayonne))
    expect(page).to have_selector("h1", text: "PELH de Bayonne")
    expect(page).to have_text("Aucune commune assignée à ce guichet.")

    # A notification should be displayed
    # The dialog should be closed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "excludes a commune from the office without deleting it" do
    visit admin_office_path(pelp_bayonne)

    # A table of communes should be present
    # with a button to exclude them
    #
    within :table_row, { "Commune" => "64102" }, text: "Bayonne" do
      click_on "Exclure cette commune du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure cette commune du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The user should not appears anymore
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "La commune a été exclue du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "La commune a été exclue du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    # The commune should remains in database
    #
    expect { bayonne.reload }.not_to change(bayonne, :persisted?)
  end

  it "selects and excludes one commune from the office page" do
    visit admin_office_path(pelp_bayonne)

    # Checkboxes should be present to select communes
    #
    within :table_row, { "Commune" => "64102" }, text: "Bayonne" do
      check
    end

    # A message should diplay the number of selected communes
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 commune sélectionnée" do
      click_on "Exclure les communes du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure la commune sélectionnée du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The selected communes should not appears anymore
    # Other communes should remain
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les communes sélectionnées ont été exclues du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les communes sélectionnées ont été exclues du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    # The commune should remains in database
    #
    expect { bayonne.reload }.not_to change(bayonne, :persisted?)
  end

  it "selects and excludes all communes from the current page on the office page without deleting them" do
    # Create a bunch of communes to have several pages
    #
    pelp_bayonne.communes << create_list(:commune, 10, departement: pelp_bayonne.departement)

    visit admin_office_path(pelp_bayonne)

    expect(page).to have_text("12 communes | Page 1 sur 2")

    # Checkboxes should be present to select all communes
    #
    within "#datatable-communes" do
      check nil, match: :first
    end

    # A message should diplay the number of selected communes
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 communes sélectionnées" do
      click_on "Exclure les communes du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure les 10 communes sélectionnées du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The selected communes should have been removed
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_text("2 communes | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, { "Commune" => "64102" }, text: "Bayonne")
    expect(page).to have_no_selector(:table_row, { "Commune" => "64122" }, text: "Biarritz")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les communes sélectionnées ont été exclues du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les communes sélectionnées ont été exclues du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    # The communes should remains in database
    #
    expect { bayonne.reload }.not_to change(bayonne, :persisted?)
  end

  it "selects and excludes all communes through several pages on the office page" do
    # Create a bunch of communes to have several pages
    #
    pelp_bayonne.communes << create_list(:commune, 10, departement: pelp_bayonne.departement)

    visit admin_office_path(pelp_bayonne)

    expect(page).to have_text("12 communes | Page 1 sur 2")

    # Checkboxes should be present to select all communes
    #
    within "#datatable-communes" do
      check nil, match: :first
    end

    # A message should diplay the number of selected communes
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 communes sélectionnées" do
      click_on "Sélectionner les 12 communes des 2 pages"
    end

    within ".datatable__selection", text: "12 communes sélectionnées" do
      click_on "Exclure les communes du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure les 12 communes sélectionnées du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # No communes should appear anymore
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_text("Aucune commune assignée à ce guichet.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les communes sélectionnées ont été exclues du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les communes sélectionnées ont été exclues du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    # The communes should remains in database
    #
    expect { bayonne.reload }.not_to change(bayonne, :persisted?)
  end
end
