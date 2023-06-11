# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#show" do
  subject(:request) do
    get "/paquets/#{package.id}/transmission", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:package) { create(:package) }

  pending "add some examples (or delete) #{__FILE__}"
end
