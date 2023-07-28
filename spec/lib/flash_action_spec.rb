# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashAction do
  let(:action) do
    { label: "Home", url: "/" }
  end

  let(:multiple_actions) do
    [
      { label: "Home", url: "/" },
      { label: "Cancel", url: "/", method: "post" }
    ]
  end

  context "without cache store", cache_store: :null_store do
    context "with only one action" do
      subject(:result) do
        described_class.write(action)
      end

      it "returns the same object on write" do
        expect(result).to eq(action)
      end

      it "retrieves the same object on read" do
        expect(described_class.read(result)).to eq(action)
      end
    end

    context "with multiple actions" do
      subject(:result) do
        described_class.write_multi(multiple_actions)
      end

      it "computes and returns computed hashes on write" do
        expect(result).to eq(multiple_actions)
      end

      it "retrieves the same hashes on read" do
        expect(described_class.read(result)).to eq(multiple_actions)
      end
    end
  end

  context "with cache store", cache_store: :memory_store do
    context "with only one action" do
      subject(:result) do
        described_class.write(action)
      end

      it "returns a cache key on write" do
        expect(result).to eq("flash_actions/e92065047d5a34358cdf919938b00946b677f792e9d8eca39021fe6f37358732")
      end

      it "retrieves the original object from cache on read" do
        expect(described_class.read(result)).to eq(action)
      end
    end

    context "with multiple actions" do
      subject(:result) do
        described_class.write_multi(multiple_actions)
      end

      it "returns a sets of cache keys on write" do
        expect(result).to eq([
          "flash_actions/e92065047d5a34358cdf919938b00946b677f792e9d8eca39021fe6f37358732",
          "flash_actions/02dcd971fa19ac6ffac43490362187164f363c6c7d397ee3be249902cf10c9f6"
        ])
      end

      it "retrieves the computed hashes from cache on read" do
        expect(described_class.read_multi(result)).to eq(multiple_actions)
      end
    end
  end
end
