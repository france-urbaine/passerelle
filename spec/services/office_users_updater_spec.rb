# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficeUsersUpdater do
  subject(:updater) do
    described_class.new(office)
  end

  let!(:office) { create(:office) }
  let!(:ddfip)  { office.ddfip }
  let!(:users)  { create_list(:user, 4, organization: ddfip) }

  it "updates the office users by passing their IDs" do
    ids = users[0..1].map(&:id)

    expect {
      updater.update(ids)
      office.reload
    }.to change {
      # Because default order is unpredictable.
      # We sort them by ID to avoid flacky test
      office.users.sort_by(&:id)
    }.from([])
      .to(users[0..1].sort_by(&:id))
  end

  it "removes office users that weren't passed with their IDs" do
    office.users = users[0..1]
    ids = users[1..2].map(&:id)

    expect {
      updater.update(ids)
      office.reload
    }.to change {
      # Because default order is unpredictable.
      # We sort them by ID to avoid flacky test
      office.users.sort_by(&:id)
    }.from(users[0..1].sort_by(&:id))
      .to(users[1..2].sort_by(&:id))
  end

  it "ignores users from another organization" do
    ids = create_list(:user, 2, :ddfip)

    expect {
      updater.update(ids)
      office.reload
    }.not_to change { office.users.to_a }.from([])
  end
end
