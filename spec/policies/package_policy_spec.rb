# frozen_string_literal: true

require "rails_helper"

RSpec.describe PackagePolicy, stub_factories: false do
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
      let(:record) { create(:package, :transmitted_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :transmitted_through_web_ui, collectivity_publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted as sandbox through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted as sandbox through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization, sandbox: true) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted and covered by the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "with package transmitted as sandbox and covered by the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  it { expect(:new?).to           be_an_alias_of(policy, :not_supported) }
  it { expect(:create?).to        be_an_alias_of(policy, :not_supported) }
  it { expect(:edit?).to          be_an_alias_of(policy, :not_supported) }
  it { expect(:update?).to        be_an_alias_of(policy, :not_supported) }
  it { expect(:remove?).to        be_an_alias_of(policy, :not_supported) }
  it { expect(:destroy?).to       be_an_alias_of(policy, :not_supported) }
  it { expect(:undiscard?).to     be_an_alias_of(policy, :not_supported) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :not_supported) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :not_supported) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :not_supported) }

  describe "default relation scope" do
    subject!(:scope) { apply_relation_scope(target) }

    let(:target) { Package.all }

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
          SELECT DISTINCT "packages".*
          FROM            "packages"
          INNER JOIN      "reports"  ON "reports"."package_id" = "packages"."id"
          INNER JOIN      "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."sandbox" = FALSE
            AND  "reports"."discarded_at" IS NULL
            AND  "communes"."code_departement" = '#{current_organization.code_departement}'
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP user" do
      it { is_expected.to be_a_null_relation }
    end
  end
end
