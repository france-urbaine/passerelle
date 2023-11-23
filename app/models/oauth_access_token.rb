# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id                     :uuid             not null, primary key
#  resource_owner_id      :uuid
#  application_id         :uuid             not null
#  token                  :string           not null
#  refresh_token          :string
#  expires_in             :integer
#  scopes                 :string
#  created_at             :datetime         not null
#  revoked_at             :datetime
#  previous_refresh_token :string           default(""), not null
#
# Indexes
#
#  index_oauth_access_tokens_on_application_id     (application_id)
#  index_oauth_access_tokens_on_refresh_token      (refresh_token) UNIQUE
#  index_oauth_access_tokens_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_tokens_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (application_id => oauth_applications.id)
#  fk_rails_...  (resource_owner_id => publishers.id) ON DELETE => cascade
#

class OauthAccessToken < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken

  audited associated_with: :application
end
