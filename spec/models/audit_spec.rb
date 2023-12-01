# frozen_string_literal: true

require "rails_helper"

RSpec.describe Audit do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to belong_to(:oauth_application).optional }
  end

  describe "before_create" do
    it "fill organization with user's" do
      user  = create(:user)
      audit = create(:audit, user: user)
      expect(audit.organization).to eq(user.organization)
    end

    it "fill publisher current publisher" do
      publisher                             = create(:publisher)
      Audited.store[:current_publisher]     = publisher
      audit                                 = create(:audit)
      expect(audit.publisher).to eq(publisher)
    end

    it "fill application with current application" do
      oauth_application                     = create(:oauth_application)
      Audited.store[:current_application]   = oauth_application
      audit                                 = create(:audit)
      expect(audit.oauth_application).to eq(oauth_application)
    end

    it "fill acton attribute with 'complete' value" do
      report = create(:report)
      report.update!(completed_at: Time.now.utc)
      expect(report.audits.descending.first.action).to eq("complete")
    end

    it "fill acton attribute with 'discard' value" do
      report = create(:report)
      report.discard
      expect(report.audits.descending.first.action).to eq("discard")
    end

    it "fill acton attribute with 'login' value" do
      user = create(:user)
      user.update!(
        sign_in_count: user.sign_in_count.to_i + 1,
        last_sign_in_at: Time.now.utc - 1.hour,
        current_sign_in_at: Time.now.utc
      )
      expect(user.audits.last.action).to eq("login")
    end

    it "fill acton attribute with 'change_organization' value (update on organization_id)" do
      user = create(:user)
      user.update!(
        organization: create(:publisher)
      )
      expect(user.audits.last.action).to eq("change_organization")
    end

    it "fill acton attribute with 'change_organization' value (update on organization_id plus other attributes)" do
      user = create(:user)
      user.update!(
        last_name: "de #{user.last_name}",
        organization: create(:publisher)
      )
      expect(user.audits.last.action).to eq("change_organization_and_update")
    end
  end
end
