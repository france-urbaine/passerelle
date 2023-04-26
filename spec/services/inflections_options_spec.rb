# frozen_string_literal: true

require "rails_helper"

RSpec.describe InflectionsOptions do
  it "is initializable with a single word" do
    options = described_class.new("commune")

    aggregate_failures do
      expect(options.singular).to eq("commune")
      expect(options.plural).to eq("communes")
    end
  end

  it "is initializable with an irregular inflections" do
    options = described_class.new(
      singular: "établissement publique",
      plural: "établissements publiques"
    )

    aggregate_failures do
      expect(options.singular).to eq("établissement publique")
      expect(options.plural).to eq("établissements publiques")
    end
  end

  it "is initializable with a model" do
    options = described_class.new(Commune)

    aggregate_failures do
      expect(options.singular).to eq("commune")
      expect(options.plural).to eq("communes")
    end
  end

  it "is initializable with an acronym model" do
    options = described_class.new(DDFIP)

    aggregate_failures do
      expect(options.singular).to eq("DDFIP")
      expect(options.plural).to eq("DDFIPs")
    end
  end

  it "is initializable with another InflectionOption" do
    options = described_class.new(
      described_class.new("commune")
    )

    aggregate_failures do
      expect(options.singular).to eq("commune")
      expect(options.plural).to eq("communes")
    end
  end

  it "returns nil without arguments" do
    expect(described_class.new).to be_nil
  end

  it "raise an exception when mixing arguments and keyword arguments" do
    expect { described_class.new("commune", singular: "commune") }
      .to raise_exception(ArgumentError)
  end

  it "raise an exception without singular word" do
    expect { described_class.new(plural: "communes") }
      .to raise_exception(ArgumentError)
  end
end
