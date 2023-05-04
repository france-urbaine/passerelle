# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashAction::Cancel do
  subject(:cancel) do
    described_class.new(ActionController::Parameters.new(params))
  end

  describe "#to_h" do
    subject(:to_h) do
      cancel.to_h
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
        expect(to_h).to eq(
          label:  "Annuler",
          url:    "/collectivites/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
          method: "patch",
          params: {}
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

        expect(to_h).to eq(
          label:  "Annuler",
          url:    "/collectivites/undiscard",
          method: "patch",
          params: { ids: %w[ef9a7632 dad1aaca] }
        )
      end

      it "includes filter params in options" do
        params.merge!(
          search: "Nord",
          order:  "name",
          page:   2,
          ids:    %w[ef9a7632 dad1aaca]
        )

        expect(to_h).to eq(
          label:  "Annuler",
          url:    "/collectivites/undiscard",
          method: "patch",
          params: {
            ids:    %w[ef9a7632 dad1aaca],
            search: "Nord",
            order:  "name",
            page:   2
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

      it { expect { to_h }.to raise_exception(NotImplementedError) }
    end
  end

  describe "#to_session", cache_store: :memory_store do
    subject(:to_session) do
      cancel.to_session
    end

    let(:params) do
      {
        controller: "collectivities",
        action:     "destroy",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      }
    end

    it "returns a cache key" do
      expect(to_session).to eq("flash_actions/7020980f0986c9ccae5fa1579712472b85d631488e2d05343bfcd9f41ea2ec3c")
    end

    it "retrieves the computed hash from cache" do
      expect(Rails.cache.read(to_session)).to eq({
        label:  "Annuler",
        url:    "/collectivites/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
        method: "patch",
        params: {}
      })
    end
  end
end
