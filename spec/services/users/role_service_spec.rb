# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RoleService do
  subject(:service) do
    described_class.new(user)
  end

  context "when user is from a collectivity" do
    let(:user) { build_stubbed(:user, :collectivity) }

    it do
      aggregate_failures do
        expect(service.user_role).to eq(:collectivity)
        expect(service.viewer_type).to eq(:collectivity)
      end
    end
  end

  context "when user is a publisher" do
    let(:user) { build_stubbed(:user, :publisher) }

    it do
      aggregate_failures do
        expect(service.user_role).to eq(:publisher)
        expect(service.viewer_type).to eq(:collectivity)
      end
    end
  end

  context "when user is from DGFIP" do
    let(:user) { build_stubbed(:user, :dgfip) }

    it do
      aggregate_failures do
        expect(service.user_role).to eq(:dgfip)
        expect(service.viewer_type).to eq(:ddfip_admin)
      end
    end
  end

  context "when user is from DDFIP" do
    context "when user is an organization admin" do
      let(:user) { build_stubbed(:user, :ddfip, :organization_admin) }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:ddfip_admin)
          expect(service.viewer_type).to eq(:ddfip_admin)
        end
      end
    end

    context "when user is a form admin" do
      let(:user) { build_stubbed(:user, :ddfip, :form_admin) }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:ddfip_form_admin)
          expect(service.viewer_type).to eq(:ddfip_admin)
        end
      end
    end

    context "when user is has no specific role" do
      let(:user) { build_stubbed(:user, :ddfip) }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:ddfip_user)
          expect(service.viewer_type).to eq(:ddfip_user)
        end
      end
    end
  end

  context "when setting organization type directly" do
    subject(:service) do
      described_class.new(nil, organization: organization)
    end

    context "when organization is an ApplicationRecord" do
      let(:organization) { build_stubbed(:collectivity) }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:collectivity)
          expect(service.viewer_type).to eq(:collectivity)
        end
      end
    end

    context "when organization is a string" do
      let(:organization) { "ddfip" }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:ddfip_user)
          expect(service.viewer_type).to eq(:ddfip_user)
        end
      end
    end

    context "when organization is a symbol" do
      let(:organization) { :dgfip }

      it do
        aggregate_failures do
          expect(service.user_role).to eq(:dgfip)
          expect(service.viewer_type).to eq(:ddfip_admin)
        end
      end
    end
  end
end
