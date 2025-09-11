# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  shared_context "when organization has IP ranges" do
    let(:ip_ranges) { ["192.168.3.3", "192.168.2.0/24"] }
    let(:headers) do
      (super() || {}).reverse_merge({
        "Client-Ip" => ip,
        "X-Forwarded-For" => ip
      })
    end

    before do
      current_user.organization.ip_ranges = ip_ranges if current_user
    end
  end

  shared_context "when the IP is authorized" do
    let(:ip) { "192.168.2.18" }
    include_context "when organization has IP ranges"
  end

  shared_context "when the IP is not authorized" do
    let(:ip) { "192.168.3.18" }
    include_context "when organization has IP ranges"
  end

  describe "Verify IP" do
    context "when requesting a protected controller" do
      subject(:request) do
        get "/", as:, headers:, params:
      end

      it_behaves_like "when the IP is authorized" do
        it_behaves_like "it allows access to publisher user"
        it_behaves_like "it allows access to publisher admin"
        it_behaves_like "it allows access to publisher super admin"
        it_behaves_like "it allows access to collectivity user"
        it_behaves_like "it allows access to collectivity admin"
        it_behaves_like "it allows access to collectivity super admin"
        it_behaves_like "it allows access to DDFIP user"
        it_behaves_like "it allows access to DDFIP admin"
        it_behaves_like "it allows access to DDFIP super admin"
        it_behaves_like "it allows access to DGFIP user"
        it_behaves_like "it allows access to DGFIP admin"
        it_behaves_like "it allows access to DGFIP super admin"
      end
      it_behaves_like "when the IP is not authorized" do
        it_behaves_like "it denies access to publisher user"
        it_behaves_like "it denies access to publisher admin"
        it_behaves_like "it denies access to publisher super admin"
        it_behaves_like "it denies access to collectivity user"
        it_behaves_like "it denies access to collectivity admin"
        it_behaves_like "it denies access to collectivity super admin"
        it_behaves_like "it denies access to DDFIP user"
        it_behaves_like "it denies access to DDFIP admin"
        it_behaves_like "it denies access to DDFIP super admin"
        it_behaves_like "it denies access to DGFIP user"
        it_behaves_like "it denies access to DGFIP admin"
        it_behaves_like "it denies access to DGFIP super admin"
      end
    end

    context "when requesting an API endpoint", :api_request do
      subject(:request) do
        get "/collectivites", as:, headers:, params:
      end

      let(:as)        { |e| e.metadata.fetch(:as, :json) }
      let(:headers)   { (super() || {}).reverse_merge(authorization_header) }
      let(:publisher) { create(:publisher, ip_ranges:) }

      before { setup_access_token(publisher) }

      it_behaves_like "when the IP is authorized" do
        it_behaves_like "it allows access"
      end

      it_behaves_like "when the IP is not authorized" do
        it_behaves_like "it allows access"
      end
    end
  end
end
