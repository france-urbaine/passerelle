# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Timeline::Component do
  it "renders a timeline with multiple steps" do
    render_inline described_class.new do |timeline|
      timeline.with_step("Step 1", status: :done)
      timeline.with_step("Step 2", status: :current)
      timeline.with_step("Step 3", status: :failed)
      timeline.with_step("Step 4")
    end

    expect(page).to have_selector(".timeline") do |timeline|
      expect(timeline).to have_selector(".timeline-step", count: 4)

      expect(timeline).to have_selector(".timeline-step:nth-child(1)") do |step|
        expect(step).to have_html_attribute("class").to eq("timeline-step timeline-step--done")
        expect(step).to have_text("Step 1")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(2)") do |step|
        expect(step).to have_html_attribute("class").to eq("timeline-step timeline-step--current")
        expect(step).to have_text("Step 2")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(3)") do |step|
        expect(step).to have_html_attribute("class").to eq("timeline-step timeline-step--failed")
        expect(step).to have_text("Step 3")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(4)") do |step|
        expect(step).to have_html_attribute("class").to eq("timeline-step timeline-step--pending")
        expect(step).to have_text("Step 4")
      end
    end
  end

  it "renders a timeline with dates" do
    render_inline described_class.new do |timeline|
      timeline.with_step("Step 1", status: :done,   date: Date.new(2024, 9, 16))
      timeline.with_step("Step 2", status: :failed, date: Time.zone.local(2025, 2, 14, 9, 0))
      timeline.with_step("Step 3")
    end

    expect(page).to have_selector(".timeline") do |timeline|
      expect(timeline).to have_selector(".timeline-step:nth-child(1)") do |step|
        expect(step).to have_selector(".timeline-step__date", text: "16/09/2024")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(2)") do |step|
        expect(step).to have_selector(".timeline-step__date", text: "14/02/2025")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(3)") do |step|
        expect(step).to have_no_selector(".timeline-step__date")
      end
    end
  end

  it "renders a timeline with string dates" do
    render_inline described_class.new do |timeline|
      timeline.with_step("Step 1", status: :done,   date: "01/01/2024")
      timeline.with_step("Step 2", status: :failed, date: "03/2025")
      timeline.with_step("Step 3")
    end

    expect(page).to have_selector(".timeline") do |timeline|
      expect(timeline).to have_selector(".timeline-step:nth-child(1)") do |step|
        expect(step).to have_selector(".timeline-step__date", text: "01/01/2024")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(2)") do |step|
        expect(step).to have_selector(".timeline-step__date", text: "03/2025")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(3)") do |step|
        expect(step).to have_no_selector(".timeline-step__date")
      end
    end
  end

  it "renders a timeline with icons" do
    render_inline described_class.new do |timeline|
      timeline.with_step("Step 1", status: :done,   icon: "check")
      timeline.with_step("Step 2", status: :failed, icon: "envelope")
      timeline.with_step("Step 3")
    end

    expect(page).to have_selector(".timeline") do |timeline|
      expect(timeline).to have_selector(".timeline-step:nth-child(1)") do |step|
        expect(step).to have_selector("svg") do |svg|
          expect(svg).to have_html_attribute("data-source").to eq("heroicons/optimized/24/solid/check.svg")
        end
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(2)") do |step|
        expect(step).to have_selector("svg") do |svg|
          expect(svg).to have_html_attribute("data-source").to eq("heroicons/optimized/24/solid/envelope.svg")
        end
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(3)") do |step|
        expect(step).to have_no_selector("svg")
      end
    end
  end

  it "renders a timeline with text in steps" do
    render_inline described_class.new do |timeline|
      timeline.with_step("Step 1", status: :done) do
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      end

      timeline.with_step("Step 2", status: :failed) do
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
      end

      timeline.with_step("Step 3")
    end

    expect(page).to have_selector(".timeline") do |timeline|
      expect(timeline).to have_selector(".timeline-step:nth-child(1)") do |step|
        expect(step).to have_selector(".timeline-step__title",       text: "Step 1")
        expect(step).to have_selector(".timeline-step__description", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(2)") do |step|
        expect(step).to have_selector(".timeline-step__title",       text: "Step 2")
        expect(step).to have_selector(".timeline-step__description", text: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
      end

      expect(timeline).to have_selector(".timeline-step:nth-child(3)") do |step|
        expect(step).to have_selector(".timeline-step__title", text: "Step 3")
        expect(step).to have_no_selector(".timeline-step__description")
      end
    end
  end
end
