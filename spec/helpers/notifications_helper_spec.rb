# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationsHelper do
  describe "#flash_notifications", :aggregate_failures do
    it "renders simple flash messages as notifications" do
      helper.flash[:notice] = "Hello World"

      rendered_content = helper.flash_notifications
      html = Nokogiri::HTML.fragment(rendered_content)

      expect(html).to have_selector(".notifications") do |div|
        expect(div).to have_selector(".notification", text: "Hello World")
      end
    end

    it "renders complex flash messages as notifications" do
      helper.flash[:notice] = {
        scheme: "success",
        delay:  3000,
        header: "Hello World",
        body:   "Lorem lispum dolor sit amet."
      }

      rendered_content = helper.flash_notifications
      html = Nokogiri::HTML.fragment(rendered_content)

      expect(html).to have_selector(".notifications") do |div|
        expect(div).to have_selector(".notification.notification--success") do |notification|
          expect(notification).to have_html_attribute("data-notification-delay-value").with_value("3000")

          expect(notification).to have_selector(".notification__header", text: "Hello World")
          expect(notification).to have_selector(".notification__body", text: "Lorem lispum dolor sit amet.")
        end
      end
    end

    it "renders nothing when flashes are empty" do
      expect {
        rendered_content = helper.flash_notifications
        expect(rendered_content).to be_blank
      }.not_to raise_error
    end

    it "renders nothing when flashes scheme are unexpected" do
      helper.flash[:notice] = {
        scheme: "error",
        delay:  3000,
        header: "Hello World",
        body:   "Lorem lispum dolor sit amet."
      }

      expect {
        rendered_content = helper.flash_notifications
        expect(rendered_content).to be_blank
      }.not_to raise_error
    end
  end
end
