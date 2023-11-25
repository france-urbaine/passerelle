# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_access_grants
#
#  id                :uuid             not null, primary key
#  resource_owner_id :uuid             not null
#  application_id    :uuid             not null
#  token             :string           not null
#  expires_in        :integer          not null
#  redirect_uri      :text             not null
#  scopes            :string           default(""), not null
#  created_at        :datetime         not null
#  revoked_at        :datetime
#
# Indexes
#
#  index_oauth_access_grants_on_application_id     (application_id)
#  index_oauth_access_grants_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_grants_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (application_id => oauth_applications.id)
#  fk_rails_...  (resource_owner_id => publishers.id) ON DELETE => cascade
#
class OauthAccessGrant < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant
end
