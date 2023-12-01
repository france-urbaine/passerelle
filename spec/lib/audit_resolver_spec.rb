# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditResolver do
  describe "resolve_action" do
    context "without specific action resolution" do
      let(:user) { create(:user) }

      it "does not resolve action (create audit)" do
        expect(AuditResolver.resolve_action(user.audits.last)).to be_nil
      end

      it "does not resolve action (common update audit)" do
        user.update!(
          first_name: "Jean-#{user.first_name}"
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to be_nil
      end
    end

    context "with specific action resolution" do
      let(:report)       { create(:report) }
      let(:transmission) { create(:transmission) }
      let(:user)         { create(:user, organization: create(:publisher)) }

      it "has a single audit (1/3)" do
        expect(report.audits.size).to eq(1)
      end

      it "has a single audit (2/3)" do
        expect(transmission.audits.size).to eq(1)
      end

      it "has a single audit (3/3)" do
        expect(user.audits.size).to eq(1)
      end

      it "does not resolve action (1/3)" do
        expect(AuditResolver.resolve_action(report.audits.last)).to be_nil
      end

      it "does not resolve action (2/3)" do
        expect(AuditResolver.resolve_action(transmission.audits.last)).to be_nil
      end

      it "does not resolve action (3/3)" do
        expect(AuditResolver.resolve_action(user.audits.last)).to be_nil
      end

      it "resolves complete action (report)" do
        report.update!(
          completed_at: Time.now.utc
        )

        expect(AuditResolver.resolve_action(report.audits.last)).to eq("complete")
      end

      it "resolves complete action (transmission)" do
        transmission.update!(
          completed_at: Time.now.utc
        )

        expect(AuditResolver.resolve_action(transmission.audits.last)).to eq("complete")
      end

      it "resolves discard action" do
        user.discard

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("discard")
      end

      it "resolves two factors action" do
        # simulating a two factors action
        user.update!(
          consumed_timestep: user.consumed_timestep.to_i + 1
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("two_factors")
      end

      it "resolves login action" do
        # simulating a login action
        user.update!(
          sign_in_count: 5,
          last_sign_in_at: Time.now.utc - 1.hour,
          current_sign_in_at: Time.now.utc
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("login")
      end

      it "resolves organization change action 1/2" do
        # simulating a change of organization
        user.update!(
          organization: create(:publisher)
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("change_organization")
      end

      it "resolves organization change action 2/2" do
        # simulating a change of organization
        user.update!(
          organization: create(:collectivity)
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("change_organization")
      end

      it "resolves organization change and update action" do
        # simulating a login action
        user.update!(
          organization: create(:publisher),
          first_name: "Jean-#{user.first_name}"
        )

        expect(AuditResolver.resolve_action(user.audits.last)).to eq("change_organization_and_update")
      end
    end
  end
end
