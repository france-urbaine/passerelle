# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to belong_to(:inviter).optional }
    it { is_expected.to have_many(:invitees) }

    it { is_expected.to have_many(:transmissions) }
    it { is_expected.to have_many(:assigned_reports) }
    it { is_expected.to have_one(:active_transmission) }

    it { is_expected.to have_many(:office_users) }
    it { is_expected.to have_many(:offices).through(:office_users) }

    it { is_expected.to have_many(:access_grants) }
    it { is_expected.to have_many(:access_tokens) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }

    it { is_expected.to validate_confirmation_of(:password).with_message("Votre mot de passe n'a pas pu être confirmé") }
    it { is_expected.to validate_length_of(:password).is_at_least(12) }

    it { is_expected.to allow_value("a.b.c@example.com", "123@mail.test").for(:email) }
    it { is_expected.not_to allow_value("invalid_email_format", "123").for(:email) }

    it "validates uniqueness of :email" do
      create(:user)
      is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity
    end

    it "ignores discarded records when validating uniqueness of :email" do
      create(:user, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_user = create(:user, :discarded)
      create(:user, email: discarded_user.email)

      expect { discarded_user.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".owned_by" do
      pending "TODO"
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for users whose names match a string" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (
                        LOWER(UNACCENT("users"."last_name")) LIKE LOWER(UNACCENT('%Hello%'))
                    OR  LOWER(UNACCENT("users"."first_name")) LIKE LOWER(UNACCENT('%Hello%'))
                  )
        SQL
      end

      it "searches for users whose names match a string with multiple words" do
        expect {
          described_class.search("Louis Funes").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (
                        LOWER(UNACCENT(CONCAT("users"."last_name", ' ', "users"."first_name"))) LIKE LOWER(UNACCENT('%Louis% %Funes%'))
                    OR  LOWER(UNACCENT(CONCAT("users"."first_name", ' ', "users"."last_name"))) LIKE LOWER(UNACCENT('%Louis% %Funes%'))
                  )
        SQL
      end

      it "searches for users whose emails match an email" do
        expect {
          described_class.search("ddfip-64@finances.gouv.fr").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (
                       "users"."email" = 'ddfip-64@finances.gouv.fr'
                    OR "users"."unconfirmed_email" = 'ddfip-64@finances.gouv.fr'
                  )
        SQL
      end

      it "searches for users whose emails match a domain" do
        expect {
          described_class.search("@finances.gouv.fr").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (
                        "users"."email" LIKE '%@finances.gouv.fr'
                    OR  "users"."unconfirmed_email" LIKE '%@finances.gouv.fr'
                  )
        SQL
      end

      it "searches for users by matching a name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (
                        LOWER(UNACCENT("users"."last_name")) LIKE LOWER(UNACCENT('%Hello%'))
                    OR  LOWER(UNACCENT("users"."first_name")) LIKE LOWER(UNACCENT('%Hello%'))
                  )
        SQL
      end

      it "searches for users by matching a last name" do
        expect {
          described_class.search(last_name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT  "users".*
          FROM    "users"
          WHERE   (LOWER(UNACCENT("users"."last_name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts users by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "users".*
          FROM     "users"
          ORDER BY UNACCENT("users"."name") ASC NULLS LAST,
                   "users"."created_at" ASC
        SQL
      end

      it "sorts users by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          ORDER BY  UNACCENT("users"."name") DESC NULLS FIRST,
                    "users"."created_at" DESC
        SQL
      end

      it "sorts users by organisation" do
        expect {
          described_class.order_by_param("organisation").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
          LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
          LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
          LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
          ORDER BY  UNACCENT(COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")) ASC NULLS LAST,
                    "users"."created_at" ASC
        SQL
      end

      it "sorts users by organisation in reversed order" do
        expect {
          described_class.order_by_param("-organisation").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
          LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
          LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
          LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
          ORDER BY  UNACCENT(COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")) DESC NULLS FIRST,
                    "users"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts users by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          ORDER BY  ts_rank_cd(to_tsvector('french', "users"."name"), to_tsquery('french', 'Hello')) DESC,
                    "users"."created_at" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts users by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          ORDER BY  UNACCENT("users"."name") ASC NULLS LAST
        SQL
      end

      it "sorts users by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          ORDER BY  UNACCENT("users"."name") ASC NULLS LAST
        SQL
      end

      it "sorts users by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          ORDER BY  UNACCENT("users"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_organization" do
      it "sorts users by organization's name without argument" do
        expect {
          described_class.order_by_organization.load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
          LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
          LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
          LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
          ORDER BY  UNACCENT(COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")) ASC NULLS LAST
        SQL
      end

      it "sorts users by organization's name in ascending order" do
        expect {
          described_class.order_by_organization(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
          LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
          LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
          LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
          ORDER BY  UNACCENT(COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")) ASC NULLS LAST
        SQL
      end

      it "sorts users by organization's name in descending order" do
        expect {
          described_class.order_by_organization(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT    "users".*
          FROM      "users"
          LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
          LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
          LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
          LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
          ORDER BY  UNACCENT(COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")) DESC NULLS FIRST
        SQL
      end
    end
  end

  # Registration process
  # ----------------------------------------------------------------------------
  describe "registration process" do
    let(:user) { create(:user, :unconfirmed, skip_confirmation_notification: false) }

    it { expect(user).not_to be_invited }
    it { expect(user).not_to be_confirmed }
    it { expect(user).not_to be_active_for_authentication }
    it { expect(user).not_to be_resetable }

    it { expect { user }.to have_sent_emails.by(1) }
    it { expect { user }.to have_sent_email.to { user.email }.with_subject("Votre inscription sur Passerelle") }
    it { expect { user }.not_to have_enqueued_job }
  end

  # Confirmation process
  # ----------------------------------------------------------------------------
  describe "confirmation process" do
    let!(:user) { create(:user, :unconfirmed, skip_confirmation_notification: false) }

    it { expect { user.confirm }.to change(user, :confirmed?).to(true) }
    it { expect { user.confirm }.to change(user, :active_for_authentication?).to(true) }
    it { expect { user.confirm }.to change(user, :resetable?).to(true) }
    it { expect { user.confirm }.not_to have_sent_emails }
  end

  # Invitation process
  # ----------------------------------------------------------------------------
  describe "invitation process" do
    describe "#invite" do
      let(:author) { build(:user) }
      let(:user) do
        user = build(:user, :unconfirmed, password: nil, skip_confirmation_notification: false)
        user.invite(by: author)
        user
      end

      it { expect(user).to     be_invited }
      it { expect(user).not_to be_confirmed }
      it { expect(user).not_to be_persisted }
      it { expect(user).not_to be_active_for_authentication }
      it { expect(user).not_to be_resetable }

      it { expect(user.password)  .to be_present }
      it { expect(user.invited_at).to be_present }
      it { expect(user.inviter)   .to eq(author) }

      it { expect { user }.not_to have_sent_emails }
      it { expect { user }.not_to have_enqueued_job }

      it { expect { user.save }.to have_sent_emails.by(1) }
      it { expect { user.save }.to have_sent_email.to(user.email).with_subject("Votre inscription sur Passerelle") }
      it { expect { user.save }.not_to have_enqueued_job }
    end

    describe "#accept_invitation" do
      let(:user) { create(:user, :invited, :unconfirmed) }

      it { expect { user.accept_invitation }.to change(user, :invited?).to(false) }
      it { expect { user.accept_invitation }.to change(user, :confirmed?).to(true) }
      it { expect { user.accept_invitation }.to change(user, :active_for_authentication?).to(true) }
      it { expect { user.accept_invitation }.to change(user, :resetable?).to(true) }

      it { expect { user.accept_invitation }.not_to have_sent_emails }
      it { expect { user.accept_invitation }.not_to have_enqueued_job }
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

  # Authentication
  # ----------------------------------------------------------------------------
  describe "authentication process" do
    describe ".find_for_authentication" do
      it "ignores discarded records" do
        expect {
          described_class.find_for_authentication(email: "ddfip-64@finances.gouv.fr")
        }.to perform_sql_query(<<~SQL.squish)
          SELECT   "users".*
          FROM     "users"
          WHERE    "users"."discarded_at" IS NULL
            AND    "users"."email" = 'ddfip-64@finances.gouv.fr'
          ORDER BY "users"."created_at" ASC,
                   "users"."id" ASC
          LIMIT    1
        SQL
      end
    end

    describe "#active_for_authentication?" do
      it "accepts kept records" do
        user = create(:user)
        expect(user).to be_active_for_authentication
      end

      it "rejects discarded records" do
        user = create(:user, :discarded)
        expect(user).not_to be_active_for_authentication
      end

      it "rejects unconfirmed users" do
        user = create(:user, :unconfirmed)
        expect(user).not_to be_active_for_authentication
      end
    end

    describe "#update_with_password_protection" do
      let(:user) { create(:user, first_name: "Jean", email: "jean@ddip.gouv.fr") }

      it "updates attributes without current password" do
        expect {
          user.update_with_password_protection(first_name: "Louis")
          user.reload
        }.to change(user, :first_name).to("Louis")
      end

      it "updates password with current password" do
        expect {
          user.update_with_password_protection(password: "czdeTobV-Bub_yZ4Q7B8", current_password: user.password)
          user.reload
        }.to change(user, :password).to(satisfy { user.valid_password?("czdeTobV-Bub_yZ4Q7B8") })
      end

      it "doesn't update password without current password" do
        expect {
          user.update_with_password_protection(password: "czdeTobV-Bub_yZ4Q7B8")
          user.reload
        }.not_to change(user, :encrypted_password)
      end

      it "doesn't update email without current password" do
        expect {
          user.update_with_password_protection(email: "louis@ddip.gouv.fr")
          user.reload
        }.not_to change(user, :email)
      end
    end
  end

  # 2FA process
  # ----------------------------------------------------------------------------
  describe "2FA process" do
    describe "#setup_two_factor" do
      let(:organization) { create(:ddfip, allow_2fa_via_email: true) }
      let(:user)         { create(:user, organization:) }

      it "set up the 2FA method" do
        expect {
          user.setup_two_factor("2fa")
        }.to not_change(user, :otp_method).from("2fa")
          .and change(user, :otp_secret).to(be_present)
          .and not_change(user, :updated_at)
      end

      it "set up the 2FA via email" do
        expect {
          user.setup_two_factor("email")
        }.to change(user, :otp_method).to("email")
          .and change(user, :otp_secret).to(be_present)
          .and not_change(user, :updated_at)
      end

      it "sends instructions with OTP code by email" do
        expect {
          user.setup_two_factor("email")
        }.to have_sent_emails.by(1)
          .and have_sent_email.to(user.email).with_subject("Activation de l'authentification en 2 étapes sur Passerelle")
      end

      it "doesn't send instructions when setting up the 2FA method" do
        expect {
          user.setup_two_factor("2fa")
        }.not_to have_sent_emails
      end

      it "ignores email method according to organization settings" do
        organization = create(:ddfip, allow_2fa_via_email: false)
        user         = create(:user, organization:)

        expect {
          user.setup_two_factor("email")
          perform_enqueued_jobs
        }.to not_change(user, :otp_method).from("2fa")
          .and change(user, :otp_secret).to(be_present)
          .and not_change(user, :updated_at)
          .and not_have_sent_emails
      end
    end

    describe "#enable_two_factor" do
      let(:organization) { create(:ddfip, allow_2fa_via_email: true) }
      let(:user)         { create(:user, organization:) }

      it "activates 2FA method" do
        expect {
          user.enable_two_factor(
            otp_method: "2fa",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
        }.to not_change(user, :otp_method).from("2fa")
          .and change(user, :otp_secret).to("64MKG4S4GZ6W7MTEWB2EBDPR")
          .and change(user, :updated_at)
      end

      it "activates 2FA method via email" do
        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
        }.to change(user, :otp_method).to("email")
          .and change(user, :otp_secret).to("64MKG4S4GZ6W7MTEWB2EBDPR")
          .and change(user, :updated_at)
      end

      it "sends a notification to user after updating its 2FA" do
        expect {
          user.enable_two_factor(
            otp_method: "2fa",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
          perform_enqueued_jobs
        }.to have_sent_emails.by(1)
          .and have_sent_email.to(user.email).with_subject("Modification de vos paramètres de sécurité sur Passerelle")
      end

      it "doesn't activate 2FA when OTP code is invalid" do
        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   "123456"
          )
        }.to not_change(user, :updated_at)
      end

      it "doesn't activate 2FA when OTP code is missing" do
        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR"
          )
        }.to not_change(user, :updated_at)
      end

      it "doesn't send any notification when OTP code is invalid" do
        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   "123456"
          )
          perform_enqueued_jobs
        }.to not_have_sent_emails
      end

      it "returns errors when OTP code is invalid" do
        user.enable_two_factor(
          otp_method: "email",
          otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
          otp_code:   "123456"
        )

        expect(user.errors).to satisfy { |errors| errors.of_kind?(:otp_code, :invalid) }
      end

      it "returns errors when OTP code is missing" do
        user.enable_two_factor(
          otp_method: "email",
          otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR"
        )

        expect(user.errors).to satisfy { |errors| errors.of_kind?(:otp_code, :blank) }
      end

      it "ignores email method according to organization settings" do
        organization = create(:ddfip, allow_2fa_via_email: false)
        user         = create(:user, organization:)

        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
        }.to not_change(user, :otp_method).from("2fa")
          .and change(user, :otp_secret).to("64MKG4S4GZ6W7MTEWB2EBDPR")
          .and change(user, :updated_at)
      end

      it "resets OTP code after succeed" do
        expect {
          user.enable_two_factor(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
        }.to not_change(user, :otp_code).from(nil)
      end
    end

    describe "#enable_two_factor_with_password" do
      let(:organization) { create(:ddfip, allow_2fa_via_email: true) }
      let(:user)         { create(:user, organization:) }

      it "activates 2FA method" do
        expect {
          user.enable_two_factor_with_password(
            otp_method:       "2fa",
            otp_secret:       "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:         ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current),
            current_password: user.password
          )
        }.to not_change(user, :otp_method).from("2fa")
          .and change(user, :otp_secret).to("64MKG4S4GZ6W7MTEWB2EBDPR")
          .and change(user, :updated_at)
      end

      it "activates 2FA method via email" do
        expect {
          user.enable_two_factor_with_password(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current),
            current_password: user.password
          )
        }.to change(user, :otp_method).to("email")
          .and change(user, :otp_secret).to("64MKG4S4GZ6W7MTEWB2EBDPR")
          .and change(user, :updated_at)
      end

      it "sends a notification to user after updating its 2FA" do
        expect {
          user.enable_two_factor_with_password(
            otp_method: "2fa",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current),
            current_password: user.password
          )
          perform_enqueued_jobs
        }.to have_sent_emails.by(1)
          .and have_sent_email.to(user.email).with_subject("Modification de vos paramètres de sécurité sur Passerelle")
      end

      it "doesn't activate 2FA when current password is invalid" do
        expect {
          user.enable_two_factor_with_password(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current),
            current_password: "monkey-business"
          )
        }.to not_change(user, :updated_at)
      end

      it "doesn't activate 2FA when current password is missing" do
        expect {
          user.enable_two_factor_with_password(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
          )
        }.to not_change(user, :updated_at)
      end

      it "doesn't activate 2FA when current password is valid but OTP code is not" do
        expect {
          user.enable_two_factor_with_password(
            otp_method: "email",
            otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
            otp_code:   "123456",
            current_password: user.password
          )
        }.to not_change(user, :updated_at)
      end

      it "returns errors when current password is invalid" do
        user.enable_two_factor_with_password(
          otp_method: "email",
          otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
          otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current),
          current_password: "monkey-business"
        )

        expect(user.errors).to satisfy { |errors| errors.of_kind?(:current_password, :invalid) }
      end

      it "returns errors when current password is missing" do
        user.enable_two_factor_with_password(
          otp_method: "email",
          otp_secret: "64MKG4S4GZ6W7MTEWB2EBDPR",
          otp_code:   ROTP::TOTP.new("64MKG4S4GZ6W7MTEWB2EBDPR").at(Time.current)
        )

        expect(user.errors).to satisfy { |errors| errors.of_kind?(:current_password, :blank) }
      end
    end

    describe "#increment_failed_attempts!" do
      let(:user) { create(:user) }

      it "increments #failed_attempts by 1" do
        expect {
          user.increment_failed_attempts!
          user.reload
        }.to change(user, :failed_attempts).to(1)
          .and not_change(user, :locked_at).from(nil)
      end

      it "locks user after exceed the maximum number of attempts" do
        user = create(:user, failed_attempts: Devise.maximum_attempts - 1)

        expect {
          user.increment_failed_attempts!
          user.reload
        }.to change(user, :failed_attempts).by(1)
          .and change(user, :locked_at).to(be_present)
      end

      it "doesn't lock again an already locked user" do
        user = create(:user, failed_attempts: Devise.maximum_attempts - 1, locked_at: 1.day.ago)

        expect {
          user.increment_failed_attempts!
          user.reload
        }.to change(user, :failed_attempts).by(1)
          .and not_change(user, :locked_at).from(be_present)
      end

      it "sends instructions to unlock user after exceed the maximum number of attempts" do
        user = create(:user, failed_attempts: Devise.maximum_attempts - 1)

        expect {
          user.increment_failed_attempts!
          perform_enqueued_jobs
        }.to have_sent_emails.by(1)
          .and have_sent_email.to(user.email).with_subject("Verrouillage de votre compte Passerelle")
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
            .to change { users[0].reload.offices_count }.from(0).to(1)
            .and not_change { users[1].reload.offices_count }.from(0)
        end

        it "changes when users is removed from the office" do
          office.users << users[0]

          expect { office.users.delete(users[0]) }
            .to change { users[0].reload.offices_count }.from(1).to(0)
            .and not_change { users[1].reload.offices_count }.from(0)
        end

        it "doesn't changes when another user is added" do
          office.users << users[0]

          expect { office.users << users[1] }
            .to not_change { users[0].reload.offices_count }.from(1)
            .and change { users[1].reload.offices_count }.from(0).to(1)
        end
      end
    end
  end
end
