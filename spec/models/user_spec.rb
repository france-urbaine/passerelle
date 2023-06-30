# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to belong_to(:inviter).optional }
    it { is_expected.to have_many(:invitees) }

    it { is_expected.to have_many(:office_users) }
    it { is_expected.to have_many(:offices).through(:office_users) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_confirmation_of(:password).with_message("Votre mot de passe n'a pas pu être confirmé") }
    it { is_expected.to validate_length_of(:password).is_at_least(12) }

    it { is_expected.to allow_value("a.b.c@example.com", "123@mail.test").for(:email) }
    it { is_expected.not_to allow_value("invalid_email_format", "123").for(:email) }

    it "ignores discarded users when validating uniqueness of email" do
      create(:user, :discarded, email: "foo@bar.com")

      expect(build(:user, email: "foo@bar.com")).to be_valid
    end

    it "skips uniqueness validation on discarded users" do
      create(:user, email: "foo@bar.com")

      expect(build(:user, :discarded, email: "foo@bar.com")).to be_valid
    end

    it "validates email uniqueness when resetting discarded_at" do
      create(:user, email: "foo@bar.com")
      user = create(:user, :discarded, email: "foo@bar.com")
      user.discarded_at = nil

      expect(user).not_to be_valid
    end

    it "raises an exception when undiscarding an user but its email is already taker by another user" do
      user = create(:user, :discarded, email: "foo@bar.com")
      create(:user, email: "foo@bar.com")

      expect { user.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "users".*
        FROM   "users"
        WHERE (LOWER(UNACCENT("users"."last_name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT("users"."first_name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect {
        described_class.search("Louis Funes").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "users".*
        FROM   "users"
        WHERE (LOWER(UNACCENT(CONCAT("users"."last_name", ' ', "users"."first_name"))) LIKE LOWER(UNACCENT('%Louis% %Funes%'))
          OR LOWER(UNACCENT(CONCAT("users"."first_name", ' ', "users"."last_name"))) LIKE LOWER(UNACCENT('%Louis% %Funes%')))
      SQL
    end

    it do
      expect {
        described_class.search("ddfip-64@finances.gouv.fr").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "users".*
        FROM   "users"
        WHERE ("users"."email" = 'ddfip-64@finances.gouv.fr' OR "users"."unconfirmed_email" = 'ddfip-64@finances.gouv.fr')
      SQL
    end

    it do
      expect {
        described_class.search("@finances.gouv.fr").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "users".*
        FROM   "users"
        WHERE ("users"."email" LIKE '%@finances.gouv.fr' OR "users"."unconfirmed_email" LIKE '%@finances.gouv.fr')
      SQL
    end
  end

  # Registration process
  # ----------------------------------------------------------------------------
  describe "registration process" do
    let!(:user) { create(:user, :unconfirmed, skip_confirmation_notification: false) }

    it { expect(user).not_to be_invited }
    it { expect(user).not_to be_confirmed }
    it { expect(user).not_to be_active_for_authentication }

    it { is_expected.to have_sent_emails.by(1) }
    it { is_expected.to have_sent_email.to(user.email).with_subject("Votre inscription sur FiscaHub") }
  end

  # Confirmation process
  # ----------------------------------------------------------------------------
  describe "confirmation process" do
    let!(:user) { create(:user, :unconfirmed, skip_confirmation_notification: false) }

    it { expect { user.confirm }.to change(user, :confirmed?).to(true) }
    it { expect { user.confirm }.to change(user, :active_for_authentication?).to(true) }
    it { expect { user.confirm }.not_to have_sent_emails }
  end

  # Invitation process
  # ----------------------------------------------------------------------------
  describe "invitation process" do
    describe "#invite" do
      let!(:user)   { build(:user, :unconfirmed, password: nil, skip_confirmation_notification: false) }
      let!(:author) { build(:user) }

      before { user.invite(by: author) }

      it { expect(user).to     be_invited }
      it { expect(user).not_to be_confirmed }
      it { expect(user).not_to be_persisted }
      it { expect(user).not_to be_active_for_authentication }

      it { expect(user.password)  .to be_present }
      it { expect(user.invited_at).to be_present }
      it { expect(user.inviter)   .to eq(author) }

      it { is_expected.not_to have_sent_emails }

      it { expect { user.save }.to have_sent_emails.by(1) }
      it { expect { user.save }.to have_sent_email.to(user.email).with_subject("Votre inscription sur FiscaHub") }
    end

    describe "#accept_invitation" do
      let!(:user) { create(:user, :invited, :unconfirmed) }

      it { expect { user.accept_invitation }.to change(user, :invited?).to(false) }
      it { expect { user.accept_invitation }.to change(user, :confirmed?).to(true) }
      it { expect { user.accept_invitation }.to change(user, :active_for_authentication?).to(true) }
      it { expect { user.accept_invitation }.not_to have_sent_emails }
    end

    describe ".find_by_invitation_token" do
      let(:unconfimed_user) { create(:user, :invited, :unconfirmed) }
      let(:expired_user)    { Timecop.freeze(1.month.ago) { create(:user, :invited, :unconfirmed) } }
      let(:confimed_user)   { create(:user, :invited, confirmation_token: Devise.friendly_token) }

      let(:valid_token)     { unconfimed_user.confirmation_token }
      let(:expired_token)   { expired_user.confirmation_token }
      let(:completed_token) { confimed_user.confirmation_token }
      let(:unknown_token)   { Devise.friendly_token }

      it "finds unconfirmed user without errors" do
        aggregate_failures do
          user = User.find_by_invitation_token(valid_token)
          expect(user).to eq(unconfimed_user)
          expect(user.errors).to be_empty
        end
      end

      it "finds and set errors to unconfirmed with expired token" do
        aggregate_failures do
          user = User.find_by_invitation_token(expired_token)
          expect(user).to eq(expired_user)
          expect(user.errors).to satisfy { |errors| errors.of_kind?(:email, :confirmation_period_expired) }
        end
      end

      it "finds and set errors to already confirmed user" do
        aggregate_failures do
          user = User.find_by_invitation_token(completed_token)
          expect(user).to eq(confimed_user)
          expect(user.errors).to satisfy { |errors| errors.of_kind?(:email, :already_confirmed) }
        end
      end

      it "builds a new user and set errors with unknown token" do
        aggregate_failures do
          user = User.find_by_invitation_token(unknown_token)
          expect(user).to be_a_new(User)
          expect(user.errors).to satisfy { |errors| errors.of_kind?(:confirmation_token, :invalid) }
        end
      end

      it "builds a new user and set errors with blank token" do
        aggregate_failures do
          user = User.find_by_invitation_token("")
          expect(user).to be_a_new(User)
          expect(user.errors).to satisfy { |errors| errors.of_kind?(:confirmation_token, :blank) }
        end
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      let!(:users) { create_list(:user, 2) }

      it { expect { reset_all_counters }.to ret(2) }
      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_users_counters()") }

      describe "on offices_count" do
        before do
          offices = create_list(:office, 6)

          users[0].offices = offices.shuffle.take(4)
          users[1].offices = offices.shuffle.take(2)

          User.update_all(offices_count: 0)
        end

        it { expect { reset_all_counters }.to change { users[0].reload.offices_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { users[1].reload.offices_count }.from(0).to(2) }
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database triggers" do
    describe "about counter caches" do
      let!(:users) { create_list(:user, 2) }

      describe "#offices_count" do
        let(:office) { create(:office) }

        it "changes when users is assigned to the office" do
          expect { office.users << users[0] }
            .to      change { users[0].reload.offices_count }.from(0).to(1)
            .and not_change { users[1].reload.offices_count }.from(0)
        end

        it "changes when users is removed from the office" do
          office.users << users[0]

          expect { office.users.delete(users[0]) }
            .to      change { users[0].reload.offices_count }.from(1).to(0)
            .and not_change { users[1].reload.offices_count }.from(0)
        end

        it "doesn't changes when another user is added" do
          office.users << users[0]

          expect { office.users << users[1] }
            .to  not_change { users[0].reload.offices_count }.from(1)
            .and     change { users[1].reload.offices_count }.from(0).to(1)
        end
      end
    end
  end
end
