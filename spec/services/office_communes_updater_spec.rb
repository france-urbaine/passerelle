# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficeCommunesUpdater do
  subject(:updater) do
    described_class.new(office)
  end

  let!(:office)      { create(:office) }
  let!(:departement) { office.ddfip.departement }
  let!(:communes)    { create_list(:commune, 4, departement: departement) }

  it "updates the office communes by passing their codes INSEE" do
    codes_insee = communes[0..1].map(&:code_insee)

    expect {
      updater.update(codes_insee)
      office.reload
    }.to change {
      # Because default order is unpredictable.
      # We sort them by ID to avoid flacky test
      office.communes.sort_by(&:id)
    }.from([])
      .to(communes[0..1].sort_by(&:id))
  end

  it "removes office communes that weren't passed with the codes" do
    office.communes = communes[0..1]
    codes_insee = communes[1..2].map(&:code_insee)

    expect {
      updater.update(codes_insee)
      office.reload
    }.to change {
      # Because default order is unpredictable.
      # We sort them by ID to avoid flacky test
      office.communes.sort_by(&:id)
    }.from(communes[0..1].sort_by(&:id))
      .to(communes[1..2].sort_by(&:id))
  end
end
