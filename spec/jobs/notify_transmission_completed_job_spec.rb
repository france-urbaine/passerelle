# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyTransmissionCompletedJob do
  let(:transmission) { create(:transmission) }
  let!(:packages)    { create_list(:package, 2, :transmitted_to_ddfip, transmission: transmission) }
  let!(:users) do
    [
      create(:user, :organization_admin, :ddfip),
      create(:user, :organization_admin, organization: packages[1].ddfip),
      create(:user, :organization_admin, organization: packages[1].ddfip),
      create(:user, organization: packages[1].ddfip)
    ]
  end

  it "sends asynchronous email to the admins of the concerned DDFIP" do
    expect {
      described_class.perform_now(transmission)
      perform_enqueued_jobs
    }
      .to have_sent_email.to(users[0].email).with_subject("Vous avez reçu de nouveaux signalements")
      .to have_sent_email.to(users[1].email).with_subject("Vous avez reçu de nouveaux signalements")
  end
end
