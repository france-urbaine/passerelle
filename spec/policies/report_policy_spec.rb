# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportPolicy, stub_factories: false do
  shared_context "when current user is member of targeted office" do
    include_context "when current user is a DDFIP user"
    before do
      create(:office, competences: [record.form_type], users: [current_user], communes: [record.commune])
    end
  end

  describe_rule :index? do
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a DDFIP user")         { succeed }
    it_behaves_like("when current user is a DGFIP admin")        { succeed }
    it_behaves_like("when current user is a DGFIP user")         { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  describe_rule :show? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { succeed }
      it_behaves_like("when current user is a DGFIP admin")        { succeed }
      it_behaves_like("when current user is a DGFIP user")         { succeed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with report" do
      let(:record) { build_stubbed(:report) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "when reported through Web UI by the current collectivity" do
        let(:record) { create(:report, :reported_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { create(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :reported_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :transmitted_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { create(:report, :reported_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { create(:report, :reported_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { create(:report, :reported_for_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when package is assigned by the current DDFIP" do
        let(:record) { create(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when package is returned by the current DDFIP" do
        let(:record) { create(:report, :returned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to any DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, package_sandbox: false) }

        it_behaves_like("when current user is a DGFIP admin")             { succeed }
        it_behaves_like("when current user is a DGFIP user")              { succeed }
      end

      context "when transmitted as sandbox to any DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, package_sandbox: true) }

        it_behaves_like("when current user is a DGFIP admin")             { failed }
        it_behaves_like("when current user is a DGFIP user")              { failed }
      end
    end
  end

  describe_rule :create? do
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a DGFIP admin")        { failed }
    it_behaves_like("when current user is a DGFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  it { expect(:new?).to be_an_alias_of(policy, :create?) }

  describe_rule :update? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { succeed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with report" do
      let(:record) { build_stubbed(:report) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "when reported through Web UI by the current collectivity" do
        let(:record) { create(:report, :reported_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { create(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :reported_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :transmitted_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { create(:report, :reported_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { create(:report, :reported_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { create(:report, :reported_for_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when package is assigned by the current DDFIP" do
        let(:record) { create(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when package is returned by the current DDFIP" do
        let(:record) { create(:report, :returned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  it { expect(:edit?).to be_an_alias_of(policy, :update?) }

  describe_rule :destroy? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with report" do
      let(:record) { build_stubbed(:report) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "when reported through Web UI by the current collectivity" do
        let(:record) { create(:report, :reported_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { create(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :reported_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { create(:report, :transmitted_through_web_ui, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { create(:report, :reported_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { create(:report, :transmitted_through_api, collectivity: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { create(:report, :reported_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { create(:report, :transmitted_through_api, publisher: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { create(:report, :reported_for_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { create(:report, :transmitted_to_ddfip, ddfip: current_organization, package_sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when package is assigned by the current DDFIP" do
        let(:record) { create(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when package is returned by the current DDFIP" do
        let(:record) { create(:report, :returned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  it { expect(:remove?).to    be_an_alias_of(policy, :destroy?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :destroy?) }

  describe_rule :destroy_all? do
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  it { expect(:remove_all?).to    be_an_alias_of(policy, :destroy_all?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :destroy_all?) }

  describe "relation scope" do
    subject!(:scope) { apply_relation_scope(target) }

    let(:target) { Report.all }

    it_behaves_like("when current user is a collectivity user") do
      it "scopes on reports reported through the web UI or transmitted through API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "reports"."discarded_at" IS NULL
            AND  "packages"."sandbox" = FALSE
            AND  "reports"."collectivity_id" = '#{current_organization.id}'
            AND  ("packages"."publisher_id" IS NULL OR "packages"."transmitted_at" IS NOT NULL)
        SQL
      end
    end

    it_behaves_like("when current user is a publisher user") do
      it "scopes on reports reported through the API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "reports"."discarded_at" IS NULL
            AND  "reports"."publisher_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin") do
      it "scopes on reports transmitted to the DDFIP" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "reports"."discarded_at" IS NULL
            AND  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."sandbox" = FALSE
            AND  "communes"."code_departement" = '#{current_organization.code_departement}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP user") do
      it "scopes on reports forwarded to their office by the DDFIP" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "packages"        ON "packages"."id" = "reports"."package_id"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          INNER JOIN "offices"         ON "offices"."id" = "office_communes"."office_id"
          INNER JOIN "office_users"    ON "offices"."id" = "office_users"."office_id"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "reports"."discarded_at" IS NULL
            AND  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."sandbox" = FALSE
            AND  "packages"."assigned_at" IS NOT NULL
            AND  "packages"."returned_at" IS NULL
            AND  "office_users"."user_id" = '#{current_user.id}'
            AND  ("reports"."form_type" = ANY ("offices"."competences"))
        SQL
      end
    end
  end
end
