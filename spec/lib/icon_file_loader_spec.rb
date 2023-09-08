# frozen_string_literal: true

require "rails_helper"

RSpec.describe IconFileLoader do
  context "without cache" do
    subject(:icon_file_loader) { IconFileLoader.new }

    it "finds and return SVG content from assets icons" do
      expect(
        icon_file_loader.named("chevron-left-small.svg")
      ).to eq(
        Rails.root.join("app/assets/icons/chevron-left-small.svg").read
      )
    end

    it "finds and return SVG content from assets image" do
      expect(
        icon_file_loader.named("logo.svg")
      ).to eq(
        Rails.root.join("app/assets/images/logo.svg").read
      )
    end

    it "finds and return SVG content from vendorized icons" do
      expect(
        icon_file_loader.named("heroicons/outline/x-mark.svg")
      ).to eq(
        Rails.root.join("vendor/assets/icons/heroicons/outline/x-mark.svg").read
      )
    end

    it "raise an exception when icon is not found" do
      expect {
        icon_file_loader.named("fooo.svg")
      }.to raise_error(InlineSvg::AssetFile::FileNotFound)
    end
  end

  context "with cache" do
    subject(:icon_file_loader) { IconFileLoader.new(cache: true) }

    it "finds and return SVG content from assets icons" do
      expect(
        icon_file_loader.named("chevron-left-small.svg")
      ).to eq(
        Rails.root.join("app/assets/icons/chevron-left-small.svg").read
      )
    end

    it "finds and return SVG content from assets image" do
      expect(
        icon_file_loader.named("logo.svg")
      ).to eq(
        Rails.root.join("app/assets/images/logo.svg").read
      )
    end

    it "finds and return SVG content from vendorized icons" do
      expect(
        icon_file_loader.named("heroicons/outline/x-mark.svg")
      ).to eq(
        Rails.root.join("vendor/assets/icons/heroicons/outline/x-mark.svg").read
      )
    end

    it "raise an exception when icon is not found" do
      expect {
        icon_file_loader.named("fooo.svg")
      }.to raise_error(InlineSvg::AssetFile::FileNotFound)
    end
  end
end
