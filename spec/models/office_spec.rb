# frozen_string_literal: true

require "rails_helper"

RSpec.describe Office do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:ddfip).required }
  it { is_expected.to have_many(:office_users) }
  it { is_expected.to have_many(:office_communes) }
  it { is_expected.to have_many(:users).through(:office_users) }
  it { is_expected.to have_many(:communes).through(:office_communes) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:action) }

  it do
    is_expected.to validate_inclusion_of(:action)
      .in_array(%w[evaluation_hab evaluation_eco occupation_hab occupation_eco])
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:office1) { create(:office) }
    let!(:office2) { create(:office) }

    describe "#users_count" do
      let(:user) { create(:user) }

      it "changes when users is assigned to the office" do
        expect { office1.users << user }
          .to      change { office1.reload.users_count }.from(0).to(1)
          .and not_change { office2.reload.users_count }.from(0)
      end

      it "changes when users is removed from the office" do
        office1.users << user

        expect { office1.users.delete(user) }
          .to      change { office1.reload.users_count }.from(1).to(0)
          .and not_change { office2.reload.users_count }.from(0)
      end

      it "changes when users is destroyed" do
        office1.users << user

        expect { user.destroy }
          .to      change { office1.reload.users_count }.from(1).to(0)
          .and not_change { office2.reload.users_count }.from(0)
      end

      it "changes when discarding" do
        office1.users << user
        expect { user.discard }
          .to      change { office1.reload.users_count }.from(1).to(0)
          .and not_change { office2.reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        office1.users << user

        expect { user.undiscard }
          .to      change { office1.reload.users_count }.from(0).to(1)
          .and not_change { office2.reload.users_count }.from(0)
      end
    end

    describe "#communes_count" do
      let!(:commune) { create(:commune, code_insee: "64102") }

      it "changes when communes is assigned to the office" do
        expect { office1.communes << commune }
          .to      change { office1.reload.communes_count }.from(0).to(1)
          .and not_change { office2.reload.communes_count }.from(0)
      end

      it "changes when an existing code_insee is assigned to the office" do
        expect { office1.office_communes.create(code_insee: "64102") }
          .to      change { office1.reload.communes_count }.from(0).to(1)
          .and not_change { office2.reload.communes_count }.from(0)
      end

      it "doesn't change when an unknown code_insee is assigned to the office" do
        expect { office1.office_communes.create(code_insee: "64024") }
          .to  not_change { office1.reload.communes_count }.from(0)
          .and not_change { office2.reload.communes_count }.from(0)
      end

      it "changes when commune is removed from the office" do
        office1.communes << commune

        expect { office1.communes.delete(commune) }
          .to      change { office1.reload.communes_count }.from(1).to(0)
          .and not_change { office2.reload.communes_count }.from(0)
      end

      it "changes when commune is destroyed" do
        office1.communes << commune

        expect { commune.destroy }
          .to      change { office1.reload.communes_count }.from(1).to(0)
          .and not_change { office2.reload.communes_count }.from(0)
      end

      it "changes when commune updates its code_insee" do
        office1.communes << commune

        expect { commune.update(code_insee: "64024") }
          .to      change { office1.reload.communes_count }.from(1).to(0)
          .and not_change { office2.reload.communes_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:office1) { create(:office) }
    let!(:office2) { create(:office) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_offices_counters()") }

    describe "on users_count" do
      before do
        users = create_list(:user, 6)

        office1.users = users.shuffle.take(4)
        office2.users = users.shuffle.take(2)

        Office.update_all(users_count: 0)
      end

      it { expect { reset_all_counters }.to change { office1.reload.users_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { office2.reload.users_count }.from(0).to(2) }
    end

    describe "on communes_count" do
      before do
        communes = create_list(:commune, 6)

        office1.communes = communes.shuffle.take(4)
        office2.communes = communes.shuffle.take(2)

        Office.update_all(communes_count: 0)
      end

      it { expect { reset_all_counters }.to change { office1.reload.communes_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { office2.reload.communes_count }.from(0).to(2) }
    end
  end
end
