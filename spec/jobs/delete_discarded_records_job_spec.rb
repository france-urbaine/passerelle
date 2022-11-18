# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeleteDiscardedRecordsJob do
  before do
    publisher           = create(:publisher)
    discarded_publisher = create(:publisher, discarded_at: 31.days.ago)
    create(:publisher, discarded_at: 1.day.ago)
    create(:publisher, discarded_at: 45.days.ago)

    create(:collectivity, publisher: publisher)
    create(:collectivity, publisher: publisher, discarded_at: 1.day.ago)
    create(:collectivity, publisher: publisher, discarded_at: 31.days.ago)
    create(:collectivity, publisher: publisher, discarded_at: 45.days.ago)
    create(:collectivity, publisher: discarded_publisher)

    ddfip           = create(:ddfip)
    discarded_ddfip = create(:ddfip, discarded_at: 31.days.ago)
    create(:ddfip, discarded_at: 5.days.ago)

    create(:service, ddfip: ddfip)
    create(:service, ddfip: ddfip, discarded_at: 1.day.ago)
    create(:service, ddfip: ddfip, discarded_at: 5.days.ago)
    create(:service, ddfip: ddfip, discarded_at: 31.days.ago)
    create(:service, ddfip: discarded_ddfip)

    create(:user, organization: publisher)
    create(:user, organization: publisher, discarded_at: 1.hour.ago)
    create(:user, organization: publisher, discarded_at: 1.day.ago)
    create(:user, organization: discarded_publisher)
  end

  it do
    expect { described_class.perform_now }
      .to  change { Publisher.with_discarded.count    }.by(-2)
      .and change { Collectivity.with_discarded.count }.by(-3)
      .and change { DDFIP.with_discarded.count        }.by(-1)
      .and change { Service.with_discarded.count      }.by(-2)
      .and change { User.with_discarded.count         }.by(-2)
  end
end
