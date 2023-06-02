# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publisher do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:collectivities) }
    it { is_expected.to have_many(:packages) }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }

    it { is_expected.to     allow_value("801453893").for(:siren) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren) }
    it { is_expected.not_to allow_value("1234567891").for(:siren) }

    it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
    it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

    context "with an existing publisher" do
      # FYI: About uniqueness validations, case insensitivity and accents:
      # You should read ./docs/uniqueness_validations_and_accents.md
      before { create(:publisher) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }
    end

    context "when existing publisher is discarded" do
      before { create(:publisher, :discarded) }

      it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.not_to validate_uniqueness_of(:siren).case_insensitive }
    end
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "publishers"."siren" = 'Hello')
      SQL
    end
  end

  # Order scope
  # ----------------------------------------------------------------------------
  describe ".order_by_param" do
    it do
      expect {
        described_class.order_by_param("name").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY UNACCENT("publishers"."name") ASC, "publishers"."created_at" ASC
      SQL
    end

    it do
      expect {
        described_class.order_by_param("-name").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY UNACCENT("publishers"."name") DESC, "publishers"."created_at" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect {
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY ts_rank_cd(to_tsvector('french', "publishers"."name"), to_tsquery('french', 'Hello')) DESC,
                 "publishers"."created_at" ASC
      SQL
    end
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:publishers) { create_list(:publisher, 2) }

    describe "#users_count" do
      let(:user) { create(:user, organization: publishers[0]) }

      it "changes on creation" do
        expect { user }
          .to      change { publishers[0].reload.users_count }.from(0).to(1)
          .and not_change { publishers[1].reload.users_count }.from(0)
      end

      it "changes on deletion" do
        user
        expect { user.destroy }
          .to      change { publishers[0].reload.users_count }.from(1).to(0)
          .and not_change { publishers[1].reload.users_count }.from(0)
      end

      it "changes when discarding" do
        user
        expect { user.discard }
          .to      change { publishers[0].reload.users_count }.from(1).to(0)
          .and not_change { publishers[1].reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        expect { user.undiscard }
          .to      change { publishers[0].reload.users_count }.from(0).to(1)
          .and not_change { publishers[1].reload.users_count }.from(0)
      end

      it "changes when updating organization" do
        user
        expect { user.update(organization: publishers[1]) }
          .to  change { publishers[0].reload.users_count }.from(1).to(0)
          .and change { publishers[1].reload.users_count }.from(0).to(1)
      end
    end

    describe "#collectivities_count" do
      let(:collectivity) { create(:collectivity, publisher: publishers[0]) }

      it "changes on creation" do
        expect { collectivity }
          .to      change { publishers[0].reload.collectivities_count }.from(0).to(1)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes on discarding" do
        collectivity
        expect { collectivity.discard }
          .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes on undiscarding" do
        collectivity.discard
        expect { collectivity.undiscard }
          .to      change { publishers[0].reload.collectivities_count }.from(0).to(1)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes on deletion" do
        collectivity
        expect { collectivity.destroy }
          .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "doesn't change when deleting a discarded collectivity" do
        collectivity.discard
        expect { collectivity.destroy }
          .to  not_change { publishers[0].reload.collectivities_count }.from(0)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes when updating publisher" do
        collectivity
        expect { collectivity.update(publisher: publishers[1]) }
          .to  change { publishers[0].reload.collectivities_count }.from(1).to(0)
          .and change { publishers[1].reload.collectivities_count }.from(0).to(1)
      end

      it "doesn't change when updating publisher of a discarded collectivity" do
        collectivity.discard
        expect { collectivity.update(publisher: publishers[1]) }
          .to  not_change { publishers[0].reload.collectivities_count }.from(0)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes when combining updating publisher and discarding" do
        collectivity
        expect { collectivity.update(publisher: publishers[1], discarded_at: Time.current) }
          .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
          .and not_change { publishers[1].reload.collectivities_count }.from(0)
      end

      it "changes when combining updating publisher and undiscarding" do
        collectivity.discard
        expect { collectivity.update(publisher: publishers[1], discarded_at: nil) }
          .to  not_change { publishers[0].reload.collectivities_count }.from(0)
          .and     change { publishers[1].reload.collectivities_count }.from(0).to(1)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:publishers) { create_list(:publisher, 2) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_publishers_counters()") }

    describe "on users_count" do
      before do
        create_list(:user, 4, organization: publishers[0])
        create_list(:user, 2, organization: publishers[1])
        create_list(:user, 1, :publisher)
        create_list(:user, 1, :collectivity)

        Publisher.update_all(users_count: 0)
      end

      it { expect { reset_all_counters }.to change { publishers[0].reload.users_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { publishers[1].reload.users_count }.from(0).to(2) }
    end

    describe "on collectivities_count" do
      before do
        create_list(:collectivity, 3, publisher: publishers[0])
        create_list(:collectivity, 2, publisher: publishers[1])
        create_list(:collectivity, 2, :discarded, publisher: publishers[1])

        Publisher.update_all(collectivities_count: 0)
      end

      it { expect { reset_all_counters }.to change { publishers[0].reload.collectivities_count }.from(0).to(3) }
      it { expect { reset_all_counters }.to change { publishers[1].reload.collectivities_count }.from(0).to(2) }
    end
  end
end
