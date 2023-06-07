# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#edit" do
  subject(:request) do
    get "/signalements/#{report.id}/edit", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  pending "TODO"
end
