# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Packages::ApprovalsController#update" do
  subject(:request) do
    patch "/paquets/#{package.id}/approval", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:package) { create(:package) }

  pending "add some examples (or delete) #{__FILE__}"
end
