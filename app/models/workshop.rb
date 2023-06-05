# frozen_string_literal: true

# == Schema Information
#
# Table name: workshops
#
#  id           :uuid             not null, primary key
#  ddfip_id     :uuid             not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#  due_on       :date
#
# Indexes
#
#  index_workshops_on_ddfip_id      (ddfip_id)
#  index_workshops_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (ddfip_id => ddfips.id) ON DELETE => cascade
#
class Workshop < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :ddfip
  has_many :reports, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name, presence: true
end
