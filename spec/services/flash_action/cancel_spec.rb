# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashAction::Cancel do
  describe "#to_h" do
    it "returns options to cancel a #destroy" do
      params = ActionController::Parameters.new({
        controller: "users",
        action:     "destroy",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      })

      expect(
        described_class.new(params).to_h
      ).to eq(
        label:  "Annuler",
        url:    "/utilisateurs/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
        method: "patch",
        params: {}
      )
    end

    it "returns options to cancel a #destroy_all with multiple ids" do
      params = ActionController::Parameters.new({
        controller: "users",
        action:     "destroy_all",
        ids:        %w[ef9a7632 dad1aaca]
      })

      expect(
        described_class.new(params).to_h
      ).to eq(
        label:  "Annuler",
        url:    "/utilisateurs/undiscard",
        method: "patch",
        params: { ids: %w[ef9a7632 dad1aaca] }
      )
    end

    it "returns options to cancel a #destroy_all with filter params" do
      params = ActionController::Parameters.new({
        controller: "users",
        action:     "destroy_all",
        search:     "Nord",
        order:      "name",
        page:       2,
        ids:        %w[ef9a7632 dad1aaca]
      })

      expect(
        described_class.new(params).to_h
      ).to eq(
        label:  "Annuler",
        url:    "/utilisateurs/undiscard",
        method: "patch",
        params: {
          ids:    %w[ef9a7632 dad1aaca],
          search: "Nord",
          order:  "name",
          page:   2
        }
      )
    end

    it "returns options to cancel a #destroy_all with all ids and filters" do
      params = ActionController::Parameters.new({
        controller: "users",
        action:     "destroy_all",
        search:     "Nord",
        order:      "name",
        page:       2,
        ids:        "all"
      })

      expect(
        described_class.new(params).to_h
      ).to eq(
        label:  "Annuler",
        url:    "/utilisateurs/undiscard",
        method: "patch",
        params: {
          ids:    "all",
          search: "Nord",
          order:  "name",
          page:   2
        }
      )
    end

    it "raise exception on unexpeced action" do
      params = ActionController::Parameters.new({
        controller: "users",
        action:     "update",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      })

      expect {
        described_class.new(params).to_h
      }.to raise_exception(NotImplementedError)
    end

    it "build nested URL" do
      params = ActionController::Parameters.new({
        controller:   "users",
        action:       "destroy_all",
        publisher_id: "ef9a7632-b0ac-4994-914b-2786836e853f",
        ids:          "all"
      })

      expect(
        described_class.new(params).to_h
      ).to eq(
        label:  "Annuler",
        url:    "/editeurs/ef9a7632-b0ac-4994-914b-2786836e853f/utilisateurs/undiscard",
        method: "patch",
        params: {
          ids:    "all"
        }
      )
    end
  end

  describe "#to_session", cache_store: :memory_store do
    subject(:cancel_action) do
      described_class.new(ActionController::Parameters.new(params))
    end

    let(:params) do
      {
        controller: "users",
        action:     "destroy",
        id:         "ef9a7632-b0ac-4994-914b-2786836e853f"
      }
    end

    it "returns a cache key" do
      expect(cancel_action.to_session).to eq("flash_actions/c3d45332a0e685f65317f66fabd54694b029890cf30e43d8734fb80c15a989ef")
    end

    it "retrieves the computed hash from cache" do
      expect(
        Rails.cache.read(cancel_action.to_session)
      ).to eq({
        label:  "Annuler",
        url:    "/utilisateurs/ef9a7632-b0ac-4994-914b-2786836e853f/undiscard",
        method: "patch",
        params: {}
      })
    end
  end
end
