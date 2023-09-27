# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransmissionPolicy, stub_factories: false do
  describe_rule :show? do
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end

  describe_rule :create? do
    context "without record" do
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with transmissible report" do
      # TODO : change it after Report factory rework
      let(:record) do
        report = create(:report, :reported_through_web_ui)
        report.update(package_id: nil)
      end

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a collectivity user")  { succeed }
    end

    context "with intransmissible report" do
      let(:record) { create(:report, :transmitted_through_web_ui) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end
  end

  describe_rule :complete? do
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end
end
