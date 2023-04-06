# frozen_string_literal: true

require "rails_helper"

RSpec.describe Service do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:ddfip).required }

  it { is_expected.to have_many(:user_services) }
  it { is_expected.to have_many(:users).through(:user_services) }

  it { is_expected.to have_many(:service_communes) }
  it { is_expected.to have_many(:communes).through(:service_communes) }

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
    let!(:service1) { create(:service) }
    let!(:service2) { create(:service) }

    describe "#users_count" do
      let(:user) { create(:user) }

      it "changes when users is assigned to the service" do
        expect { service1.users << user }
          .to      change { service1.reload.users_count }.from(0).to(1)
          .and not_change { service2.reload.users_count }.from(0)
      end

      it "changes when users is removed from the service" do
        service1.users << user

        expect { service1.users.delete(user) }
          .to      change { service1.reload.users_count }.from(1).to(0)
          .and not_change { service2.reload.users_count }.from(0)
      end

      it "changes when users is destroyed" do
        service1.users << user

        expect { user.destroy }
          .to      change { service1.reload.users_count }.from(1).to(0)
          .and not_change { service2.reload.users_count }.from(0)
      end

      it "changes when discarding" do
        service1.users << user
        expect { user.discard }
          .to      change { service1.reload.users_count }.from(1).to(0)
          .and not_change { service2.reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        service1.users << user

        expect { user.undiscard }
          .to      change { service1.reload.users_count }.from(0).to(1)
          .and not_change { service2.reload.users_count }.from(0)
      end
    end

    describe "#communes_count" do
      let!(:commune) { create(:commune, code_insee: "64102") }

      it "changes when communes is assigned to the service" do
        expect { service1.communes << commune }
          .to      change { service1.reload.communes_count }.from(0).to(1)
          .and not_change { service2.reload.communes_count }.from(0)
      end

      it "changes when an existing code_insee is assigned to the service" do
        expect { service1.service_communes.create(code_insee: "64102") }
          .to      change { service1.reload.communes_count }.from(0).to(1)
          .and not_change { service2.reload.communes_count }.from(0)
      end

      it "doesn't change when an unknown code_insee is assigned to the service" do
        expect { service1.service_communes.create(code_insee: "64024") }
          .to  not_change { service1.reload.communes_count }.from(0)
          .and not_change { service2.reload.communes_count }.from(0)
      end

      it "changes when commune is removed from the service" do
        service1.communes << commune

        expect { service1.communes.delete(commune) }
          .to      change { service1.reload.communes_count }.from(1).to(0)
          .and not_change { service2.reload.communes_count }.from(0)
      end

      it "changes when commune is destroyed" do
        service1.communes << commune

        expect { commune.destroy }
          .to      change { service1.reload.communes_count }.from(1).to(0)
          .and not_change { service2.reload.communes_count }.from(0)
      end

      it "changes when commune updates its code_insee" do
        service1.communes << commune

        expect { commune.update(code_insee: "64024") }
          .to      change { service1.reload.communes_count }.from(1).to(0)
          .and not_change { service2.reload.communes_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:service1) { create(:service) }
    let!(:service2) { create(:service) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_services_counters()") }

    describe "on users_count" do
      before do
        users = create_list(:user, 6)

        service1.users = users.shuffle.take(4)
        service2.users = users.shuffle.take(2)

        Service.update_all(users_count: 0)
      end

      it { expect { reset_all_counters }.to change { service1.reload.users_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { service2.reload.users_count }.from(0).to(2) }
    end

    describe "on communes_count" do
      before do
        communes = create_list(:commune, 6)

        service1.communes = communes.shuffle.take(4)
        service2.communes = communes.shuffle.take(2)

        Service.update_all(communes_count: 0)
      end

      it { expect { reset_all_counters }.to change { service1.reload.communes_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { service2.reload.communes_count }.from(0).to(2) }
    end
  end
end
