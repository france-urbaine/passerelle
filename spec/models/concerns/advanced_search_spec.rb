# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdvancedSearch do
  describe ".advanced_search" do
    it "performs a SQL query from a simple String" do
      expect {
        Publisher.advanced_search(
          "Solutions",
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT  "publishers".*
        FROM    "publishers"
        WHERE   ("publishers"."name" = 'Solutions' OR "publishers"."siren" = 'Solutions')
      SQL
    end

    it "performs a SQL query from a Hash" do
      expect {
        Publisher.advanced_search(
          { name: "Solutions" },
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE  "publishers"."name" = 'Solutions'
      SQL
    end

    it "performs a SQL query from a Hash with string keys" do
      expect {
        Publisher.advanced_search(
          { "name" => "Solutions" },
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE  "publishers"."name" = 'Solutions'
      SQL
    end

    it "performs a SQL query from parameters" do
      expect {
        Publisher.advanced_search(
          ActionController::Parameters.new("name" => "Solutions"),
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE  "publishers"."name" = 'Solutions'
      SQL
    end

    it "performs a SQL query from an advanced String using only hash-like style" do
      expect {
        Publisher.advanced_search(
          "name:(Solutions & Territoire) siren:123456789",
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE  "publishers"."name" = 'Solutions & Territoire'
          AND  "publishers"."siren" = '123456789'
      SQL
    end

    it "performs a SQL query from an advanced String using a individual value" do
      expect {
        Publisher.advanced_search(
          "name:(Solutions & Territoire) siren:123456789 Marc",
          scopes: {
            name:  -> { where(name: _1) },
            siren: -> { where(siren: _1) }
          }
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE  ("publishers"."name" = 'Marc' OR "publishers"."siren" = 'Marc')
          AND  "publishers"."name" = 'Solutions & Territoire'
          AND  "publishers"."siren" = '123456789'
      SQL
    end
  end

  describe ".parse_advanced_search_input" do
    it "parses a simple String" do
      expect(Publisher.parse_advanced_search_input("Solutions")).to eq([
        "Solutions",
        {}
      ])
    end

    it "parses a Hash with soybol keys" do
      expect(
        Publisher.parse_advanced_search_input({ name: "Solutions" })
      ).to eq([
        nil,
        { "name" => "Solutions" }
      ])
    end

    it "parses a Hash with string keys" do
      expect(
        Publisher.parse_advanced_search_input({ "name" => "Solutions" })
      ).to eq([
        nil,
        { "name" => "Solutions" }
      ])
    end

    it "parses parameters" do
      expect(
        Publisher.parse_advanced_search_input(ActionController::Parameters.new("name" => "Solutions"))
      ).to eq([
        nil,
        { "name" => "Solutions" }
      ])
    end

    it "parses an advanced String using only hash-like style" do
      expect(
        Publisher.parse_advanced_search_input("name:(Solutions & Territoire) siren:123456789")
      ).to eq([
        "",
        { "name" => "Solutions & Territoire", "siren" => "123456789" }
      ])
    end

    it "parses an advanced String using a individual value" do
      expect(
        Publisher.parse_advanced_search_input("name:(Solutions & Territoire) Marc")
      ).to eq([
        "Marc",
        { "name" => "Solutions & Territoire" }
      ])
    end

    it "parses an advanced String with multiple values" do
      expect(
        Publisher.parse_advanced_search_input("contact:(marc, jean, thomas)")
      ).to eq([
        "",
        { "contact" => %w[marc jean thomas] }
      ])
    end
  end

  describe ".flatten_advanced_search_input" do
    it "returns the same simple String" do
      expect(
        Publisher.flatten_advanced_search_input(
          "Solutions",
          {}
        )
      ).to eq("Solutions")
    end

    it "returns a String representation of a Hash" do
      expect(
        Publisher.flatten_advanced_search_input(
          "",
          { "name" => "Solutions & Territoire", "siren" => "123456789" }
        )
      ).to eq("name:(Solutions & Territoire) siren:123456789")
    end

    it "returns a String representation of a Hash+String" do
      expect(
        Publisher.flatten_advanced_search_input(
          "Marc",
          { "name" => "Solutions & Territoire" }
        )
      ).to eq("name:(Solutions & Territoire) Marc")
    end

    it "flattens an Hash with multiple values" do
      expect(
        Publisher.flatten_advanced_search_input(
          "",
          { "contact" => %w[marc jean thomas] }
        )
      ).to eq("contact:(marc,jean,thomas)")
    end

    it "flattens an Hash with a single-value Array" do
      expect(
        Publisher.flatten_advanced_search_input(
          "",
          { "contact" => %w[marc] }
        )
      ).to eq("contact:marc")
    end
  end
end
