# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlHelper do
  it "acts like a String" do
    expect(
      described_class.new("/some/path")
    )
      .to  eq("/some/path")
      .and be_a(String)
      .and be_an(UrlHelper)
  end

  it "converts to a String" do
    expect(
      described_class.new("/some/path").to_s
    )
      .to  eq("/some/path")
      .and be_a(String)
      .and not_be_an(UrlHelper)
  end

  it "is inspected as a String" do
    expect(
      described_class.new("/some/path").inspect
    )
      .to  eq("\"/some/path\"")
      .and be_a(String)
      .and not_be_an(UrlHelper)
  end

  it "returns the base of the URL" do
    expect(
      described_class.new("/some/path?bar=foo").base
    )
      .to  eq("/some/path")
      .and be_an(UrlHelper)
  end

  it "returns joins params to an URL without query" do
    expect(
      described_class.new("/some/path").join(foo: "bar")
    )
      .to  eq("/some/path?foo=bar")
      .and be_an(UrlHelper)
  end

  it "returns joins params to an URL with an query" do
    expect(
      described_class.new("/some/path?ids=1").join(foo: "bar")
    )
      .to  eq("/some/path?ids=1&foo=bar")
      .and be_an(UrlHelper)
  end

  it "returns the path when joins params are empty" do
    expect(
      described_class.new("/some/path?ids=1").join({})
    )
      .to  eq("/some/path?ids=1")
      .and be_an(UrlHelper)
  end
end
