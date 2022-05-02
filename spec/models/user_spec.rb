# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:organization).required }
  it { is_expected.to belong_to(:inviter).optional }
  it { is_expected.to have_many(:invitees) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:password) }

  context "with an existing user" do
    before { create(:user) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
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
    let!(:user) { create(:user, :unconfirmed) }

    it { expect(user).not_to be_invited }
    it { expect(user).not_to be_confirmed }
    it { expect(user).not_to be_active_for_authentication }

    it { is_expected.to have_sent_emails.by(1) }
    it { is_expected.to have_sent_email.to(user.email).with_subject("Instructions de confirmation") }
  end

  # Confirmation process
  # ----------------------------------------------------------------------------
  describe "confirmation process" do
    let!(:user) { create(:user, :unconfirmed) }

    it { expect { user.confirm }.to change(user, :confirmed?).to(true) }
    it { expect { user.confirm }.to change(user, :active_for_authentication?).to(true) }
    it { expect { user.confirm }.not_to have_sent_emails }
  end

  # Invitation process
  # ----------------------------------------------------------------------------
  describe "invitation process" do
    describe "#invite" do
      let!(:user)   { build(:user, :unconfirmed, password: nil) }
      let!(:author) { build(:user) }

      before { user.invite(from: author) }

      it { expect(user).to     be_invited }
      it { expect(user).not_to be_confirmed }
      it { expect(user).not_to be_persisted }
      it { expect(user).not_to be_active_for_authentication }

      it { expect(user.password)  .to be_present }
      it { expect(user.invited_at).to be_present }
      it { expect(user.inviter)   .to eq(author) }

      it { is_expected.not_to have_sent_emails }

      it { expect { user.save }.to have_sent_emails.by(1) }
      it { expect { user.save }.to have_sent_email.to(user.email).with_subject("Instructions de confirmation") }
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
      let(:confimed_user)   { create(:user, :invited, confirmation_token: Devise.friendly_token) }

      let(:valid_token)     { unconfimed_user.confirmation_token }
      let(:expired_token)   { confimed_user.confirmation_token }
      let(:unknown_token)   { Devise.friendly_token }

      it do
        expect(User.find_by_invitation_token(valid_token))
          .to eq(unconfimed_user)
          .and satisfy { |user| user.errors.empty? }
      end

      it do
        expect(User.find_by_invitation_token(expired_token))
          .to eq(confimed_user)
          .and satisfy { |user| user.errors.added?(:email, :already_confirmed) }
      end

      it do
        expect(User.find_by_invitation_token(unknown_token))
          .to be_a_new(User)
          .and satisfy { |user| user.errors.added?(:confirmation_token, :invalid) }
      end

      it do
        expect(User.find_by_invitation_token(""))
          .to be_a_new(User)
          .and satisfy { |user| user.errors.added?(:confirmation_token, :blank) }
      end
    end
  end
end
