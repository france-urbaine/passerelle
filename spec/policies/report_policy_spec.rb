# frozen_string_literal: true

require "rails_helper"
require_relative "reports/shared_example_for_target_office"

RSpec.describe ReportPolicy, type: :policy do
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
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :made_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization, sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when report is accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when report is assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when report is rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to any DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, sandbox: false) }

        it_behaves_like("when current user is a DGFIP admin") { succeed }
        it_behaves_like("when current user is a DGFIP user")  { succeed }
      end

      context "when transmitted as sandbox to any DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, sandbox: true) }

        it_behaves_like("when current user is a DGFIP admin") { failed }
        it_behaves_like("when current user is a DGFIP user")  { failed }
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

      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { succeed }
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
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :made_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization, sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

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
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted through Web UI by a collectivity owned by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity_publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :made_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when transmitted as sandbox through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, collectivity: current_organization, sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API by the current publisher" do
        let(:record) { build_stubbed(:report, :made_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { succeed }
        it_behaves_like("when current user is a publisher user")  { succeed }
      end

      context "when transmitted through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when transmitted as sandbox through API by the current publisher" do
        let(:record) { build_stubbed(:report, :transmitted_through_api, publisher: current_organization, sandbox: true) }

        it_behaves_like("when current user is a publisher admin") { failed }
        it_behaves_like("when current user is a publisher user")  { failed }
      end

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  it { expect(:remove?).to    be_an_alias_of(policy, :destroy?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :destroy?) }

  describe_rule :destroy_all? do
    it_behaves_like("when current user is a DDFIP admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  it { expect(:remove_all?).to    be_an_alias_of(policy, :destroy_all?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :destroy_all?) }

  describe_rule :transmit? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
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
        let(:record) { build_stubbed(:report, :ready, :made_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { succeed }
        it_behaves_like("when current user is a collectivity user")  { succeed }
      end

      context "when transmitted through Web UI by the current collectivity" do
        let(:record) { build_stubbed(:report, :transmitted_through_web_ui, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :ready, :made_through_api, collectivity: current_organization) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      context "when reported as sandbox through API for the current collectivity" do
        let(:record) { build_stubbed(:report, :ready, :made_through_api, collectivity: current_organization, sandbox: true) }

        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end
    end
  end

  describe_rule :accept? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  describe_rule :assign? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  describe_rule :resolve? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { succeed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  describe_rule :confirm? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  describe_rule :reject? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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

      context "when reported to the current DDFIP" do
        let(:record) { build_stubbed(:report, :made_for_office, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end
    end
  end

  describe "relation scope" do
    subject(:scope) { apply_relation_scope(Report.all) }

    it_behaves_like("when current user is a collectivity user") do
      it "scopes on reports reported through the web UI or transmitted through API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE "reports"."discarded_at" IS NULL
            AND "reports"."sandbox" = FALSE
            AND "reports"."collectivity_id" = '#{current_organization.id}'
            AND (
                 "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled', 'rejected')
              OR "reports"."publisher_id" IS NULL
            )
        SQL
      end
    end

    it_behaves_like("when current user is a publisher user") do
      it "scopes on reports reported through the API" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE "reports"."discarded_at" IS NULL
            AND "reports"."publisher_id" = '#{current_organization.id}'
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
          WHERE "reports"."discarded_at" IS NULL
            AND "reports"."sandbox" = FALSE
            AND "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled', 'rejected')
            AND "reports"."ddfip_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP user") do
      it "scopes on reports forwarded to their office by the DDFIP" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."discarded_at" IS NULL
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
