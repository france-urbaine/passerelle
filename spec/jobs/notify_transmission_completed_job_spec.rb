# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyTransmissionCompletedJob do
  let(:transmission) { create(:transmission) }
  let!(:packages)    { create_list(:package, 2, :transmitted_to_ddfip, transmission: transmission) }
  let!(:users) do
    [
      create(:user, :organization_admin, organization: packages[0].ddfip),
      create(:user, :organization_admin, organization: packages[1].ddfip)
    ]
  end

  it "sends an email to organization_admins" do
    expect { described_class.perform_now(transmission) }
      .to have_sent_email.to(users[0].email)
      .to have_sent_email.to(users[1].email)
  end
end
