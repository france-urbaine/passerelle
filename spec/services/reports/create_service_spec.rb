# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CreateService do
  subject(:service) do
    described_class.new(report, user, attributes)
  end

  let(:report)       { Report.new }
  let(:collectivity) { create(:collectivity) }
  let(:user)         { create(:user, organization: collectivity) }
  let(:attributes)   { { form_type: "evaluation_local_habitation" } }

  it "creates a report" do
    expect { service.save }
      .to  change(Report, :count).by(1)
      .and change(report, :persisted?).from(false).to(true)
      .and not_change(Package, :count)
  end
end
