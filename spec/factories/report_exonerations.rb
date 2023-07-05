# frozen_string_literal: true

FactoryBot.define do
  factory :report_exoneration do
    report
    code              { Faker::Alphanumeric.alpha(number: 2).upcase }
    label             { Faker::Lorem.sentence }
    status            { ReportExoneration::STATUSES.sample }
    base              { ReportExoneration::BASES.sample }
    code_collectivite { ReportExoneration::CODES_COLLECTIVITE.sample }
  end
end
