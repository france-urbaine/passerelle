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

  it { is_expected.to have_one(:departement).through(:ddfip) }
  it { is_expected.to have_many(:departement_communes).through(:departement) }

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
    let!(:offices) { create_list(:office, 2) }

    describe "#users_count" do
      let(:user) { create(:user) }

      it "changes when users is assigned to the office" do
        expect { offices[0].users << user }
          .to      change { offices[0].reload.users_count }.from(0).to(1)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when users is removed from the office" do
        offices[0].users << user

        expect { offices[0].users.delete(user) }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when users is destroyed" do
        offices[0].users << user

        expect { user.destroy }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when discarding" do
        offices[0].users << user
        expect { user.discard }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        offices[0].users << user

        expect { user.undiscard }
          .to      change { offices[0].reload.users_count }.from(0).to(1)
          .and not_change { offices[1].reload.users_count }.from(0)
      end
    end

    describe "#communes_count" do
      let!(:commune) { create(:commune, code_insee: "64102") }

      it "changes when communes is assigned to the office" do
        expect { offices[0].communes << commune }
          .to      change { offices[0].reload.communes_count }.from(0).to(1)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when an existing code_insee is assigned to the office" do
        expect { offices[0].office_communes.create(code_insee: "64102") }
          .to      change { offices[0].reload.communes_count }.from(0).to(1)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "doesn't change when an unknown code_insee is assigned to the office" do
        expect { offices[0].office_communes.create(code_insee: "64024") }
          .to  not_change { offices[0].reload.communes_count }.from(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune is removed from the office" do
        offices[0].communes << commune

        expect { offices[0].communes.delete(commune) }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune is destroyed" do
        offices[0].communes << commune

        expect { commune.destroy }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune updates its code_insee" do
        offices[0].communes << commune

        expect { commune.update(code_insee: "64024") }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:offices) { create_list(:office, 2) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_offices_counters()") }

    describe "on users_count" do
      before do
        users = create_list(:user, 6)

        offices[0].users = users.shuffle.take(4)
        offices[1].users = users.shuffle.take(2)

        Office.update_all(users_count: 0)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.users_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.users_count }.from(0).to(2) }
    end

    describe "on communes_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Office.update_all(communes_count: 0)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.communes_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.communes_count }.from(0).to(2) }
    end
  end
end