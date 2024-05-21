# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transmission do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:oauth_application).optional }

    it { is_expected.to have_many(:reports) }
    it { is_expected.to have_many(:packages) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    subject { build(:transmission, collectivity: collectivity) }

    let(:publisher)    { build_stubbed(:publisher) }
    let(:collectivity) { build_stubbed(:collectivity, publisher: publisher) }
    let(:user)         { build_stubbed(:user, organization: collectivity) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:publisher_id) }

    context "when setting a user_id" do
      subject { build(:transmission, collectivity: collectivity, user: user) }

      it { is_expected.to validate_absence_of(:publisher_id) }
    end

    context "when setting a publisher" do
      subject { build(:transmission, collectivity: collectivity, publisher: publisher) }

      it { is_expected.to validate_absence_of(:user_id) }
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes transmissions not yet transmitted" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."sandbox" = TRUE
        SQL
      end
    end

    describe ".out_of_sandbox" do
      it "scopes transmissions not yet transmitted" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."sandbox" = FALSE
        SQL
      end
    end

    describe ".made_through_publisher_api" do
      it "scopes on transmissions made through publisher API" do
        expect {
          described_class.made_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".made_through_web_ui" do
      it "scopes on transmissions made byt the collectivity through web UI" do
        expect {
          described_class.made_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".made_by_collectivity" do
      it "scopes on transmissions made by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.made_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on transmissions made by many collectivities" do
        expect {
          described_class.made_by_collectivity(Collectivity.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."collectivity_id" IN (
            SELECT "collectivities"."id"
            FROM   "collectivities"
            WHERE  "collectivities"."name" = 'A'
          )
        SQL
      end
    end

    describe ".made_by_publisher" do
      it "scopes on transmissions made by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.made_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on transmissions made by many publishers" do
        expect {
          described_class.made_by_publisher(Publisher.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "transmissions".*
          FROM   "transmissions"
          WHERE  "transmissions"."publisher_id" IN (
            SELECT "publishers"."id"
            FROM   "publishers"
            WHERE  "publishers"."name" = 'A'
          )
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates methods" do
    let_it_be(:publisher)      { build_stubbed(:publisher) }
    let_it_be(:collectivities) { build_stubbed_list(:collectivity, 2, publisher: publisher) }
    let_it_be(:transmissions) do
      [
        build_stubbed(:transmission, collectivity: collectivities[0]),
        build_stubbed(:transmission, collectivity: collectivities[0], publisher: publisher),
        build_stubbed(:transmission, collectivity: collectivities[1], publisher: publisher, sandbox: true),
        build_stubbed(:transmission, :completed, collectivity: collectivities[0]),
        build_stubbed(:transmission, :completed, collectivity: collectivities[0], publisher: publisher),
        build_stubbed(:transmission, :completed, collectivity: collectivities[1], publisher: publisher, sandbox: true)
      ]
    end

    describe "#out_of_sandbox?" do
      it { expect(transmissions[0]).to be_out_of_sandbox }
      it { expect(transmissions[1]).to be_out_of_sandbox }
      it { expect(transmissions[2]).not_to be_out_of_sandbox }
      it { expect(transmissions[3]).to be_out_of_sandbox }
      it { expect(transmissions[4]).to be_out_of_sandbox }
      it { expect(transmissions[5]).not_to be_out_of_sandbox }
    end

    describe "#made_through_publisher_api?" do
      it { expect(transmissions[0]).not_to be_made_through_publisher_api }
      it { expect(transmissions[1]).to     be_made_through_publisher_api }
      it { expect(transmissions[3]).not_to be_made_through_publisher_api }
      it { expect(transmissions[4]).to     be_made_through_publisher_api }
    end

    describe "#made_through_web_ui?" do
      it { expect(transmissions[0]).to     be_made_through_web_ui }
      it { expect(transmissions[1]).not_to be_made_through_web_ui }
      it { expect(transmissions[3]).to     be_made_through_web_ui }
      it { expect(transmissions[4]).not_to be_made_through_web_ui }
    end

    describe "#made_by_collectivity?" do
      it { expect(transmissions[0]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(transmissions[1]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(transmissions[2]).not_to be_made_by_collectivity(collectivities[0]) }
      it { expect(transmissions[3]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(transmissions[4]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(transmissions[5]).not_to be_made_by_collectivity(collectivities[0]) }
    end

    describe "#made_by_publisher?" do
      it { expect(transmissions[0]).not_to be_made_by_publisher(publisher) }
      it { expect(transmissions[1]).to     be_made_by_publisher(publisher) }
      it { expect(transmissions[3]).not_to be_made_by_publisher(publisher) }
      it { expect(transmissions[4]).to     be_made_by_publisher(publisher) }
    end
  end

  # Database foreign keys
  # ----------------------------------------------------------------------------
  describe "database foreign keys" do
    it "nullifies user_id when user is deleted" do
      user         = create(:user)
      transmission = create(:transmission, user:)

      user.delete
      expect { transmission.reload }.to change(transmission, :user_id).to(nil)
    end

    it "nullifies oauth_application_id when application is deleted" do
      oauth_application = create(:oauth_application)
      transmission      = create(:transmission, oauth_application:)

      oauth_application.delete
      expect { transmission.reload }.to change(transmission, :oauth_application_id).to(nil)
    end

    it "nullifies publisher_id when application is deleted" do
      publisher    = create(:publisher)
      transmission = create(:transmission, publisher:)

      publisher.delete
      expect { transmission.reload }.to change(transmission, :publisher_id).to(nil)
    end

    it "deletes tranmissions when collectivity is deleted" do
      collectivity = create(:collectivity)
      transmission = create(:transmission, collectivity:)

      collectivity.delete
      expect { transmission.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
