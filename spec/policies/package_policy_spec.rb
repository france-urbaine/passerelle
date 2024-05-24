# frozen_string_literal: true

require "rails_helper"

RSpec.describe PackagePolicy, type: :policy do
  describe_rule :index? do
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  describe_rule :show? do
    context "without record" do
      let(:record) { Package }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package" do
      let(:record) { build_stubbed(:package, :with_reports) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted through Web UI by the current collectivity" do
      let(:record) { build_stubbed(:package, :transmitted_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted through Web UI by a collectivity owned by the current publisher" do
      let(:record) { build_stubbed(:package, :transmitted_through_web_ui, collectivity_publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted through API for the current collectivity" do
      let(:record) { build_stubbed(:package, :transmitted_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted as sandbox through API for the current collectivity" do
      let(:record) { build_stubbed(:package, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted through API by the current publisher" do
      let(:record) { build_stubbed(:package, :transmitted_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted as sandbox through API by the current publisher" do
      let(:record) { build_stubbed(:package, :transmitted_through_api, publisher: current_organization, sandbox: true) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted and covered by the current DDFIP" do
      let(:record) { build_stubbed(:package, :transmitted_to_ddfip, ddfip: current_organization) }

      before do
        commune = build_stubbed(:commune, code_departement: current_organization.code_departement)
        build_stubbed(:report, commune:, package: record)
      end

      it_behaves_like("when current user is a DDFIP admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")  { succeed }
    end

    context "with package transmitted as sandbox and covered by the current DDFIP" do
      let(:record) { build_stubbed(:package, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  describe "default relation scope" do
    subject(:scope) { apply_relation_scope(Package.all) }

    it_behaves_like "when current user is a collectivity user" do
      it "scopes on packages packed through the web UI or transmitted through API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."sandbox" = FALSE
            AND  "packages"."collectivity_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes on packages packed through the API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."publisher_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes on packages transmitted to the DDFIP" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "packages".*
          FROM       "packages"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
            AND      "packages"."ddfip_id" = '#{current_user.organization_id}'
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP user" do
      it "scopes on packages assigned to the DDFIP" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT DISTINCT "packages".*
          FROM            "packages"
          INNER JOIN      "reports"  ON "reports"."package_id" = "packages"."id"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."sandbox" = FALSE
            AND  "packages"."ddfip_id" = '#{current_user.organization_id}'
            AND  "reports"."discarded_at" IS NULL
            AND  "reports"."state" IN ('assigned', 'applicable', 'inapplicable', 'approved', 'canceled')
            AND  "reports"."sandbox" = FALSE
            AND  "reports"."office_id" IN (
              SELECT "offices"."id"
              FROM "offices"
              INNER JOIN "office_users" ON "offices"."id" = "office_users"."office_id"
              WHERE "office_users"."user_id" = '#{current_user.id}'
            )
        SQL
      end
    end
  end
end
