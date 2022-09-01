# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:service).required }
  it { is_expected.to belong_to(:user).required }
end
