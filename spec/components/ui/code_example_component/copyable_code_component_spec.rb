# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeExampleComponent::CopyableCodeComponent, type: :component do
  it "renders a code copying button with proper unescaped content" do
    render_inline described_class.new(<<-TEXT)
        curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d '{&quot;grant_type&quot;:&quot;client_credentials&quot;,&quot;client_id&quot;:&quot;&#39;$CLIENT_ID&#39;&quot;,&quot;client_secret&quot;:&quot;&#39;$CLIENT_SECRET&#39;&quot;}'
    TEXT

    expect(page).to have_button(class: "icon-button") do |copy_button|
      expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
      expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
      expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value(<<-TEXT)
        curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d '{"grant_type":"client_credentials","client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'"}'
      TEXT
    end
  end
end
