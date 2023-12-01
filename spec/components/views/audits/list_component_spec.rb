# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Audits::ListComponent, type: :component do
  it "renders the list of audits for a user" do
    creation_date = Timecop.freeze(2023, 10, 23, 10, 30, 45)
    user = create(:user)
    update_date = Timecop.freeze(2023, 10, 24, 17, 15, 32)
    user.update!(
      organization: create(:publisher)
    )

    # HACK : audit user is expected set by helper "current_user" from controller
    current_user = create(:user)
    user.audits.update_all(
      user_id:   current_user.id,
      user_type: "User"
    )

    render_inline described_class.new(user.audits.descending)

    expect(user.audits.count).to eq(2)

    expect(page).to have_selector("pre.logs") do |audits_list|
      logs = audits_list.text.split("\n")

      expect(logs.size).to eq(user.audits.count)

      expect(logs.first).to have_content(
        "#{update_date.in_time_zone('Europe/Paris').strftime('%d/%m/%Y %H:%M:%S')} - Changement d'organisation réalisé par #{current_user.name}"
      )
      expect(logs.last).to have_content(
        "#{creation_date.in_time_zone('Europe/Paris').strftime('%d/%m/%Y %H:%M:%S')} - Création réalisée par #{current_user.name}"
      )
    end
  end
end
