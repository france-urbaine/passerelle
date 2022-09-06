# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeleteDiscardedUsersJob, type: :job do
  context "when user is discarded" do
    let!(:user) { create(:user, :discarded) }

    it do
      expect { described_class.perform_now(user.id) }
        .to change { User.with_discarded.count }.from(1).to(0)
    end
  end

  context "when user is undiscarded" do
    let!(:user) { create(:user) }

    it do
      expect { described_class.perform_now(user.id) }
        .not_to change { User.with_discarded.count }.from(1)
    end
  end

  context "with multiple discarded and undiscarded users" do
    let!(:users) { create_list(:user, 5) + create_list(:user, 5, :discarded) }

    it do
      expect { described_class.perform_now(*users.map(&:id)) }
        .to  change { User.discarded.count      }.from(5).to(0)
        .and change { User.with_discarded.count }.from(10).to(5)
    end
  end
end
