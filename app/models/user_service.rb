# frozen_string_literal: true

# == Schema Information
#
# Table name: user_services
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  service_id :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_services_on_service_id              (service_id)
#  index_user_services_on_service_id_and_user_id  (service_id,user_id) UNIQUE
#  index_user_services_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (service_id => services.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class UserService < ApplicationRecord
  belongs_to :user
  belongs_to :service, counter_cache: :users_count
end
