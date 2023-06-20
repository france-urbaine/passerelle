# frozen_string_literal: true

require "rails_helper"

RSpec.describe Packages::TransmissionPolicy, stub_factories: false do
  describe_rule :show? do
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

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "with package transmitted as sandbox and covered by the current DDFIP" do
      let(:record) { create(:package, :transmitted_to_ddfip, ddfip: current_organization, sandbox: true) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  describe_rule :update? do
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
end
