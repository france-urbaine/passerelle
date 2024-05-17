# frozen_string_literal: true

require "rails_helper"

RSpec.describe OauthAccessToken do
  it { is_expected.to be_a(Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken) }

  describe "audited" do
    let(:oauth_access_token) { create(:oauth_access_token) }

    it { expect(oauth_access_token.audits.last.associated).to eq(oauth_access_token.application) }
  end
end
