# frozen_string_literal: true

FactoryBot.define do
  factory :user_form_type do
    form_type { Report::FORM_TYPES.sample }
    user
  end
end
