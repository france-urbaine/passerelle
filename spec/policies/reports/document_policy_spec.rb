# frozen_string_literal: true

require "rails_helper"
require_relative "shared_example_for_target_office"
require_relative "shared_example_for_target_form_type"

RSpec.describe Reports::DocumentPolicy, type: :policy do
  describe_rule :show? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP form admin")   { succeed }
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
      it_behaves_like("when current user is a DDFIP form admin")   { failed }
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

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates another form_type")      { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when report is accepted by the current DDFIP" do
        let(:record) { build_stubbed(:report, :accepted_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates another form_type")      { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when report is assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { succeed }
        it_behaves_like("when current user administrates another form_type")      { succeed }
        it_behaves_like("when current user is member of targeted office")         { succeed }
      end

      context "when resolved as applicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :applicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { succeed }
        it_behaves_like("when current user administrates another form_type")      { succeed }
        it_behaves_like("when current user is member of targeted office")         { succeed }
      end

      context "when resolved as inapplicable by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :inapplicable, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { succeed }
        it_behaves_like("when current user administrates another form_type")      { succeed }
        it_behaves_like("when current user is member of targeted office")         { succeed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :approved_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { succeed }
        it_behaves_like("when current user administrates another form_type")      { succeed }
        it_behaves_like("when current user is member of targeted office")         { succeed }
      end

      context "when canceled by the current DDFIP" do
        let(:record) { build_stubbed(:report, :canceled_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { succeed }
        it_behaves_like("when current user administrates another form_type")      { succeed }
        it_behaves_like("when current user is member of targeted office")         { succeed }
      end

      context "when report is rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { succeed }
        it_behaves_like("when current user administrates the targeted form_type") { succeed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates another form_type")      { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
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

  describe_rule :manage? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP form admin")   { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
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

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when transmitted as sandbox to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :rejected_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")                     { failed }
        it_behaves_like("when current user is a DDFIP user")                      { failed }
        it_behaves_like("when current user administrates the targeted form_type") { failed }
        it_behaves_like("when current user is member of targeted office")         { failed }
      end
    end
  end
end
