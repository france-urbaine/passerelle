# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::LogsComponent, type: :component do
  it "renders logs" do
    render_inline described_class.new do |logs|
      logs.with_log Time.utc(2023, 11, 23, 12, 1), "Log #1"
      logs.with_log Time.utc(2023, 11, 23, 12, 2), "Log #2"
      logs.with_log Time.utc(2023, 11, 23, 12, 3), "Log #3"
    end

    expect(page).to have_selector("pre.logs") do |logs|
      expect(logs).to have_text("2023-11-23T12:01:00.000+00:00 - Log #1")
      expect(logs).to have_text("2023-11-23T12:02:00.000+00:00 - Log #2")
      expect(logs).to have_text("2023-11-23T12:03:00.000+00:00 - Log #3")
    end
  end

  it "renders logs in a given time zone" do
    render_inline described_class.new(time_zone: "CET") do |logs|
      logs.with_log Time.utc(2023, 11, 23, 12, 1), "Log #1"
      logs.with_log Time.utc(2023, 11, 23, 12, 2), "Log #2"
      logs.with_log Time.utc(2023, 11, 23, 12, 3), "Log #3"
    end

    expect(page).to have_selector("pre.logs") do |logs|
      expect(logs).to have_text("2023-11-23T13:01:00.000+01:00 - Log #1")
      expect(logs).to have_text("2023-11-23T13:02:00.000+01:00 - Log #2")
      expect(logs).to have_text("2023-11-23T13:03:00.000+01:00 - Log #3")
    end
  end

  it "renders logs with custom time format" do
    render_inline described_class.new(time_format: "%d/%m/%Y %H:%M:%S %Z") do |logs|
      logs.with_log Time.utc(2023, 11, 23, 12, 1), "Log #1"
      logs.with_log Time.utc(2023, 11, 23, 12, 2), "Log #2"
      logs.with_log Time.utc(2023, 11, 23, 12, 3), "Log #3"
    end

    expect(page).to have_selector("pre.logs") do |logs|
      expect(logs).to have_text("23/11/2023 12:01:00 UTC - Log #1")
      expect(logs).to have_text("23/11/2023 12:02:00 UTC - Log #2")
      expect(logs).to have_text("23/11/2023 12:03:00 UTC - Log #3")
    end
  end

  it "renders logs with few HTML tags" do
    render_inline described_class.new do |logs|
      logs.with_log Time.utc(2023, 11, 23, 12, 1), "Log <b>#1</b>"
      logs.with_log Time.utc(2023, 11, 23, 12, 2), "Log <b>#2</b>"
      logs.with_log Time.utc(2023, 11, 23, 12, 3), "Log <b>#3</b>"
    end

    expect(page).to have_selector("pre.logs") do |logs|
      expect(logs).to have_text("Log #1")
      expect(logs).to have_selector("b", text: "#1")
    end
  end

  it "renders escape dangerous HTML tags" do
    render_inline described_class.new do |logs|
      logs.with_log Time.utc(2023, 11, 23, 12, 1), "Log <script>alert('hello')</script>"
      logs.with_log Time.utc(2023, 11, 23, 12, 2), "Log <script>alert('hello')</script>"
      logs.with_log Time.utc(2023, 11, 23, 12, 3), "Log <script>alert('hello')</script>"
    end

    expect(page).to have_selector("pre.logs") do |logs|
      expect(logs).to have_text("Log alert('hello')")
      expect(logs).to have_no_selector("script")
    end
  end
end
