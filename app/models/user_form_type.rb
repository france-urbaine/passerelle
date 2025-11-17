# frozen_string_literal: true

# == Schema Information
#
# Table name: user_form_types
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  form_type  :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_form_types_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class UserFormType < ApplicationRecord
  belongs_to :user

  validates :form_type, presence: true, inclusion: { in: Report::FORM_TYPES }
end
