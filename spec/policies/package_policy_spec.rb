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

    context "with package created through Web UI by the current collectivity" do
      let(:record) { create(:package, :packed_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted through Web UI by the current collectivity" do
      let(:record) { create(:package, :transmitted_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package created through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :packed_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :transmitted_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package created through API for the current collectivity" do
      let(:record) { create(:package, :packed_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

    context "with package created through API by the current publisher" do
      let(:record) { create(:package, :packed_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
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

    context "with package created and covered by the current DDFIP" do
      let(:record) { create(:package, :packed_for_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
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

  describe_rule :create? do
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  it { expect(:new?).to be_an_alias_of(policy, :create?) }

  describe_rule :update? do
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
      let(:record) { create(:package, :with_reports) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through Web UI by the current collectivity" do
      let(:record) { create(:package, :packed_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted through Web UI by the current collectivity" do
      let(:record) { create(:package, :transmitted_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :packed_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :transmitted_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package created through API for the current collectivity" do
      let(:record) { create(:package, :packed_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted as sandbox through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through API by the current publisher" do
      let(:record) { create(:package, :packed_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted as sandbox through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization, sandbox: true) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package created for the current DDFIP" do
      let(:record) { create(:package, :packed_for_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "with package transmitted to the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  it { expect(:edit?).to be_an_alias_of(policy, :update?) }

  describe_rule :transmit? do
    context "without record" do
      let(:record) { Package }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package" do
      let(:record) { create(:package, :with_reports) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with uncompleted package created through Web UI by the current collectivity" do
      let(:record) { create(:package, :packed_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with completed package created through Web UI by the current collectivity" do
      let(:record) { create(:package, :packed_through_web_ui, :completed, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with completed package transmitted through Web UI by the current collectivity" do
      let(:record) { create(:package, :transmitted_through_web_ui, :completed, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with completed package created through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :packed_through_web_ui, :completed, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with uncompleted package created through API for the current collectivity" do
      let(:record) { create(:package, :packed_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with completed package created through API for the current collectivity" do
      let(:record) { create(:package, :packed_through_api, :completed, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with completed package transmitted through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, :completed, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with uncompleted package created through API by the current publisher" do
      let(:record) { create(:package, :packed_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with completed package created through API by the current publisher" do
      let(:record) { create(:package, :packed_through_api, :completed, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with completed package transmitted through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, :completed, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with completed package transmitted as sandbox through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, :completed, :sandbox, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with completed package created for the current DDFIP" do
      let(:record) { create(:package, :packed_for_ddfip, :completed, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "with completed package transmitted to the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, :completed, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  describe_rule :destroy? do
    context "without record" do
      let(:record) { Package }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package" do
      let(:record) { create(:package, :with_reports) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through Web UI by the current collectivity" do
      let(:record) { create(:package, :packed_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with package transmitted through Web UI by the current collectivity" do
      let(:record) { create(:package, :transmitted_through_web_ui, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :packed_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted through Web UI by a collectivity owned by the current publisher" do
      let(:record) { create(:package, :transmitted_through_web_ui, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package created through API for the current collectivity" do
      let(:record) { create(:package, :packed_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package transmitted as sandbox through API for the current collectivity" do
      let(:record) { create(:package, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with package created through API by the current publisher" do
      let(:record) { create(:package, :packed_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package transmitted through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end

    context "with package transmitted as sandbox through API by the current publisher" do
      let(:record) { create(:package, :transmitted_through_api, publisher: current_organization, sandbox: true) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end

    context "with package created and covered by the current DDFIP" do
      let(:record) { create(:package, :packed_for_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "with package transmitted and covered by the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
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

  describe "default relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, type: :active_record_relation)
    end

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
            AND  ("packages"."publisher_id" IS NULL OR "packages"."transmitted_at" IS NOT NULL)
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
            AND  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NULL
            AND  "reports"."discarded_at" IS NULL
            AND  "communes"."code_departement" = '#{current_organization.code_departement}'
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP user" do
      it { is_expected.to be_a_null_relation }
    end
  end

  describe "relation scope to pack a report" do
    # Subject is called before running tests to load all dependencies
    # and asserts to run only expected queries when calling `.load`
    #
    subject!(:scope) do
      policy.apply_scope(
        Package.all,
        type: :active_record_relation,
        name: :to_pack,
        scope_options: { report: report }
      )
    end

    let(:report) { build_stubbed(:report) }

    it_behaves_like("when current user is a collectivity user") do
      let(:report) { build_stubbed(:report, collectivity: current_organization) }

      it "scopes on packages not yet transmitted by the collectivity with the same action" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."transmitted_at" IS NULL
            AND  "packages"."collectivity_id" = '#{current_organization.id}'
            AND  "packages"."publisher_id" IS NULL
            AND  "packages"."action" = '#{report.action}'
        SQL
      end
    end

    it_behaves_like("when current user is a publisher user") do
      let(:report) { build_stubbed(:report, publisher: current_organization) }

      it "scopes on packages not yet transmitted by the collectivity with the same action" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."transmitted_at" IS NULL
            AND  "packages"."publisher_id" = '#{current_organization.id}'
            AND  "packages"."collectivity_id" = '#{report.collectivity.id}'
            AND  "packages"."action" = '#{report.action}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin") do
      it { is_expected.to be_a_null_relation }
    end

    it_behaves_like("when current user is a DDFIP user") do
      it { is_expected.to be_a_null_relation }
    end
  end

  describe "destroyable relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, name: :destroyable, type: :active_record_relation)
    end

    let(:target) { Package.all }

    it_behaves_like "when current user is a collectivity user" do
      it "scopes on packages packed through the web UI or transmitted through API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."collectivity_id" = '#{current_organization.id}'
            AND  "packages"."publisher_id" IS NULL
            AND  "packages"."transmitted_at" IS NULL
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
            AND  ("packages"."transmitted_at" IS NULL OR "packages"."sandbox" = TRUE)
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")  { it { is_expected.to be_a_null_relation } }
  end

  describe "undiscardable relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, name: :undiscardable, type: :active_record_relation)
    end

    let(:target) { Package.all }

    it_behaves_like "when current user is a collectivity user" do
      it "scopes on packages packed through the web UI or transmitted through API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NOT NULL
            AND  "packages"."collectivity_id" = '#{current_organization.id}'
            AND  "packages"."publisher_id" IS NULL
            AND  "packages"."transmitted_at" IS NULL
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
          WHERE  "packages"."discarded_at" IS NOT NULL
            AND  "packages"."publisher_id" = '#{current_organization.id}'
            AND  ("packages"."transmitted_at" IS NULL OR "packages"."sandbox" = TRUE)
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")  { it { is_expected.to be_a_null_relation } }
  end
end