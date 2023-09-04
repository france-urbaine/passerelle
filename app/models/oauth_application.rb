# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_applications
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  uid          :string           not null
#  secret       :string           not null
#  owner_id     :uuid
#  owner_type   :string
#  redirect_uri :text
#  scopes       :string           default(""), not null
#  confidential :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#
# Indexes
#
#  index_oauth_applications_on_owner_id_and_owner_type  (owner_id,owner_type)
#  index_oauth_applications_on_uid                      (uid) UNIQUE
#
class OauthApplication < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
end
