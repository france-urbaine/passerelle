# frozen_string_literal: true

require "rails_helper"

RSpec.describe OauthAccessGrant do
  it { is_expected.to be_a(Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant) }
end
