# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#update" do
  subject(:request) do
    patch "/signalements/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  pending "TODO"
end
