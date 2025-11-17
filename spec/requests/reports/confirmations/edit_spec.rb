# frozen_string_literal: true

require "rails_helper"
require_relative "../shared_example_for_target_form_type"

RSpec.describe "Reports::ConfirmationsController#edit" do
  subject(:request) do
    get "/signalements/confirm/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report, :resolved_as_applicable) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP form admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    context "when report has been resolved by the current DDFIP" do
      let(:report) { create(:report, :resolved_as_applicable, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has not yet been resolved by the current DDFIP" do
      let(:report) { create(:report, :assigned_to_office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has already been confirmed by the current DDFIP" do
      let(:report) { create(:report, :approved_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end
  end
end
