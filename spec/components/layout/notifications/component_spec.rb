# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Notifications::Component do
  subject(:component) { described_class.new }

  it "renders the notification from flash notice" do
    vc_test_controller.flash.now.notice = "Hello World !"

    render_inline described_class.new

    expect(page).to have_selector(".notifications") do |wrapper|
      expect(wrapper).to have_selector(".notification", text: "Hello World !") do |alert|
        expect(alert).to have_html_attribute("role").with_value("log")
        expect(alert).to have_html_attribute("aria-live").with_value("polite")
      end
    end
  end

  it "renders a notification with options" do
    vc_test_controller.flash.now.notice = {
      scheme:       "warning",
      header:       "Hello World !",
      body:         "Lorem lispum dolor sit amet.",
      delay:        10_000,
      icon:         "cloud-arrow-up",
      icon_options: { variant: :solid }
    }

    render_inline described_class.new

    expect(page).to have_selector(".notifications") do |wrapper|
      expect(wrapper).to have_selector(".notification", text: "Hello World !") do |alert|
        expect(alert).to have_html_attribute("role").with_value("log")
        expect(alert).to have_html_attribute("aria-live").with_value("polite")

        expect(alert).to have_selector(".notification__header", text: "Hello World !")
        expect(alert).to have_selector(".notification__body",   text: "Lorem lispum dolor sit amet.")

        expect(alert).to have_html_attribute("class").with_value("notification notification--warning")
        expect(alert).to have_html_attribute("data-notification-delay-value").with_value("10000")

        expect(alert).to have_selector("svg") do |svg|
          expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/solid/cloud-arrow-up.svg")
        end
      end
    end
  end

  it "renders a notification with actions" do
    vc_test_controller.flash.now.notice = {
      header: "Hello World !",
      body:   "Lorem lispum dolor sit amet."
    }

    vc_test_controller.flash.now[:actions] = [
      {
        label:  "Annuler",
        method: "patch",
        url:    "/some/path",
        params: { ids: "all" }
      }
    ]

    render_inline described_class.new

    expect(page).to have_selector(".notifications") do |wrapper|
      expect(wrapper).to have_selector(".notification", text: "Hello World !") do |alert|
        expect(alert).to have_selector(".notification__actions") do |actions|
          expect(actions).to have_selector("form") do |form|
            expect(form["method"]).to eq("post")
            expect(form["action"]).to eq("/some/path")

            expect(form).to have_selector("input[type='hidden'][name='_method'][value='patch']", visible: :hidden)
            expect(form).to have_selector("input[type='hidden'][name='ids'][value='all']", visible: :hidden)
            expect(form).to have_button("Annuler")
          end
        end
      end
    end
  end

  it "renders nothing when flashes are empty" do
    render_inline described_class.new

    expect(page.native.inner_html).to be_empty
  end

  it "raises an exception when flashes scheme are unexpected" do
    vc_test_controller.flash.now.notice = {
      scheme: "error",
      delay:  3000,
      header: "Hello World",
      body:   "Lorem lispum dolor sit amet."
    }

    expect {
      render_inline described_class.new
    }.to raise_exception(ArgumentError, "unexpected scheme: :error")
  end
end
