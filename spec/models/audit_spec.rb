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
      expect(report.audits.descending.first.action).to eq(Audit::AUDIT_ACTION_COMPLETE)
    end

    it "fill acton attribute with 'discard' value" do
      report = create(:report)
      report.discard
      expect(report.audits.descending.first.action).to eq(Audit::AUDIT_ACTION_DISCARD)
    end
  end
end
