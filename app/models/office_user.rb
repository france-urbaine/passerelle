# frozen_string_literal: true

# == Schema Information
#
# Table name: office_users
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  office_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_office_users_on_office_id              (office_id)
#  index_office_users_on_office_id_and_user_id  (office_id,user_id) UNIQUE
#  index_office_users_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class OfficeUser < ApplicationRecord
  audited

  belongs_to :office
  belongs_to :user
end
