# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeleteDiscardedRecordsJob do
  before do
    publishers = {
      "A" => create(:publisher, name: "A"),
      "B" => create(:publisher, name: "B", discarded_at: 5.days.ago),
      "C" => create(:publisher, name: "C", discarded_at: 31.days.ago),
      "D" => create(:publisher, name: "D", discarded_at: 45.days.ago)
    }

    ddfips = {
      "A" => create(:ddfip, name: "A"),
      "B" => create(:ddfip, name: "B", discarded_at: 5.days.ago),
      "C" => create(:ddfip, name: "C", discarded_at: 31.days.ago)
    }

    create(:collectivity, name: "A", publisher: publishers["A"])
    create(:collectivity, name: "B", publisher: publishers["A"], discarded_at: 5.days.ago)
    create(:collectivity, name: "C", publisher: publishers["A"], discarded_at: 31.days.ago)
    create(:collectivity, name: "D", publisher: publishers["A"], discarded_at: 45.days.ago)
    create(:collectivity, name: "E", publisher: publishers["B"])
    create(:collectivity, name: "F", publisher: publishers["C"])

    create(:office, name: "A", ddfip: ddfips["A"])
    create(:office, name: "B", ddfip: ddfips["A"], discarded_at: 5.days.ago)
    create(:office, name: "C", ddfip: ddfips["A"], discarded_at: 31.days.ago)
    create(:office, name: "D", ddfip: ddfips["B"])
    create(:office, name: "E", ddfip: ddfips["C"])

    create(:user, first_name: "A", organization: publishers["A"])
    create(:user, first_name: "B", organization: publishers["A"], discarded_at: 1.hour.ago)
    create(:user, first_name: "C", organization: publishers["A"], discarded_at: 2.days.ago)
    create(:user, first_name: "D", organization: publishers["B"])
    create(:user, first_name: "E", organization: publishers["D"])
  end

  it "destroys discarded records and their dependant records beyond a period" do
    expect { described_class.perform_now }
      .to  change { Publisher.order(:name).pluck(:name)        }.from(%w[A B C D])    .to(%w[A B])
      .and change { Collectivity.order(:name).pluck(:name)     }.from(%w[A B C D E F]).to(%w[A B E F])
      .and change { DDFIP.order(:name).pluck(:name)            }.from(%w[A B C])      .to(%w[A B])
      .and change { Office.order(:name).pluck(:name)           }.from(%w[A B C D E])  .to(%w[A B D])
      .and change { User.order(:first_name).pluck(:first_name) }.from(%w[A B C D E])  .to(%w[A B D])
  end
end
