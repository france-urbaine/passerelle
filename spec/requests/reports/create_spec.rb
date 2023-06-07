# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#new" do
  subject(:request) do
    post "/signalements", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let(:attributes) { {} }

  pending "TODO"
end
