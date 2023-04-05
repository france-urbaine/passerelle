# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashAction::Cancel do
  subject(:cancel) do
    described_class.new(ActionController::Parameters.new(params))
  end

  context "when routed to a #destroy action" do
    let(:params) do
      {
        controller: "collectivities",
        action:     "destroy",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      }
    end

    it "returns options to cancel it" do
      expect(cancel.to_h).to eq(
        label:  "Annuler",
        url:    "/collectivites/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
        method: "patch",
        params: {}
      )
    end

    it "includes redirect params in options" do
      params[:redirect] = "/editeurs/a3d25392"

      expect(cancel.to_h).to eq(
        label:  "Annuler",
        url:    "/collectivites/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
        method: "patch",
        params: { redirect: "/editeurs/a3d25392" }
      )
    end
  end

  context "when routed to a #destroy_all action" do
    let(:params) do
      {
        controller: "collectivities",
        action:     "destroy_all"
      }
    end

    it "returns options to cancel it" do
      params[:ids] = %w[ef9a7632 dad1aaca]

      expect(cancel.to_h).to eq(
        label:  "Annuler",
        url:    "/collectivites/undiscard",
        method: "patch",
        params: {
          redirect: "/collectivites",
          ids:      %w[ef9a7632 dad1aaca]
        }
      )
    end

    it "includes filter params in options" do
      params.merge!(
        search: "Nord",
        order:  "name",
        page:   2,
        ids:    %w[ef9a7632 dad1aaca]
      )

      expect(cancel.to_h).to eq(
        label:  "Annuler",
        url:    "/collectivites/undiscard",
        method: "patch",
        params: {
          redirect: "/collectivites?order=name&page=2&search=Nord",
          ids:      %w[ef9a7632 dad1aaca],
          search:   "Nord",
          order:    "name",
          page:     2
        }
      )
    end

    it "includes redirect params in options" do
      params.merge!(
        search:   "Nord",
        ids:      %w[ef9a7632 dad1aaca],
        redirect: "/editeurs/a3d25392"
      )

      expect(cancel.to_h).to eq(
        label:  "Annuler",
        url:    "/collectivites/undiscard",
        method: "patch",
        params: {
          redirect: "/editeurs/a3d25392",
          ids:      %w[ef9a7632 dad1aaca],
          search:   "Nord"
        }
      )
    end
  end

  context "when routed to another action" do
    let(:params) do
      {
        controller: "collectivities",
        action:     "update",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      }
    end

    it { expect { cancel.to_h }.to raise_exception(NotImplementedError) }
  end
end
