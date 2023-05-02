# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashAction do
  let(:literal_object) do
    { label: "Home", url: "/" }
  end

  let(:cancel_action) do
    params = { controller: "collectivities", action: "destroy_all" }
    FlashAction::Cancel.new(ActionController::Parameters.new(params))
  end

  context "without cache store", cache_store: :null_store do
    context "with a literal object" do
      subject(:result) do
        described_class.write(literal_object)
      end

      it "returns the same object on write" do
        expect(result).to eq(literal_object)
      end

      it "retrieves the same object on read" do
        expect(described_class.read(result)).to eq(literal_object)
      end
    end

    context "with a Cancel action" do
      subject(:result) do
        described_class.write(cancel_action)
      end

      it "returns the computed action" do
        expect(result).to eq(
          label:  "Annuler",
          method: "patch",
          url:    "/collectivites/undiscard",
          params: { redirect: "/collectivites" }
        )
      end

      it "retrieves the same computed action on read" do
        expect(described_class.read(result)).to eq(
          label:  "Annuler",
          method: "patch",
          url:    "/collectivites/undiscard",
          params: { redirect: "/collectivites" }
        )
      end
    end

    context "with multiple type of objects" do
      subject(:result) do
        described_class.write_multi([literal_object, cancel_action])
      end

      it "computes and returns computed hashes on write" do
        expect(result).to eq([
          {
            label: "Home",
            url: "/"
          },
          {
            label:  "Annuler",
            method: "patch",
            url:    "/collectivites/undiscard",
            params: { redirect: "/collectivites" }
          }
        ])
      end

      it "retrieves the same hashes on read" do
        expect(described_class.read(result)).to eq([
          {
            label: "Home",
            url: "/"
          },
          {
            label:  "Annuler",
            method: "patch",
            url:    "/collectivites/undiscard",
            params: { redirect: "/collectivites" }
          }
        ])
      end
    end
  end

  context "with cache store", cache_store: :memory_store do
    context "with a literal object" do
      subject(:result) do
        described_class.write(literal_object)
      end

      it "returns a cache key on write" do
        expect(result).to eq("flash_actions/e92065047d5a34358cdf919938b00946b677f792e9d8eca39021fe6f37358732")
      end

      it "retrieves the original object from cache on read" do
        expect(described_class.read(result)).to eq(literal_object)
      end
    end

    context "with a Cancel action" do
      subject(:result) do
        described_class.write(cancel_action)
      end

      it "returns a cache key on write" do
        expect(result).to eq("flash_actions/72a629628c45ed8576efd127fd779af1a6b17f8a28993b2b0385a4b06e83cd4b")
      end

      it "retrieves the computed action from cache on read" do
        expect(described_class.read(result)).to eq(
          label:  "Annuler",
          method: "patch",
          url:    "/collectivites/undiscard",
          params: { redirect: "/collectivites" }
        )
      end
    end

    context "with multiple type of objects" do
      subject(:result) do
        described_class.write_multi([literal_object, cancel_action])
      end

      it "returns a sets of cache keys on write" do
        expect(result).to eq([
          "flash_actions/e92065047d5a34358cdf919938b00946b677f792e9d8eca39021fe6f37358732",
          "flash_actions/72a629628c45ed8576efd127fd779af1a6b17f8a28993b2b0385a4b06e83cd4b"
        ])
      end

      it "retrieves the computed hashes from cache on read" do
        expect(described_class.read_multi(result)).to eq([
          {
            label: "Home",
            url: "/"
          },
          {
            label:  "Annuler",
            method: "patch",
            url:    "/collectivites/undiscard",
            params: { redirect: "/collectivites" }
          }
        ])
      end
    end
  end
end
