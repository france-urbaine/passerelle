# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "it changes collectivities count" do
  let(:subjects)     { [] }
  let(:territories)  { [] }
  let(:collectivity) { create(:collectivity, territory: territories[0]) }

  before do
    raise "you should define two subjects to check for changes" unless subjects.is_a?(Array) && subjects.size >= 2

    unless territories.is_a?(Array) && territories.size >= 2
      raise "you should define two territories that can be assigned to a collectivity"
    end
  end

  it "changes on creation" do
    expect { collectivity }
      .to change { subjects[0].reload.collectivities_count }.from(0).to(1)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes on discarding" do
    collectivity
    expect { collectivity.discard }
      .to change { subjects[0].reload.collectivities_count }.from(1).to(0)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes on undiscarding" do
    collectivity.discard
    expect { collectivity.undiscard }
      .to change { subjects[0].reload.collectivities_count }.from(0).to(1)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes on deletion" do
    collectivity
    expect { collectivity.destroy }
      .to change { subjects[0].reload.collectivities_count }.from(1).to(0)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "doesn't change when deleting a discarded collectivity" do
    collectivity.discard
    expect { collectivity.destroy }
      .to  not_change { subjects[0].reload.collectivities_count }.from(0)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes when updating territory" do
    collectivity
    expect { collectivity.update(territory: territories[1]) }
      .to  change { subjects[0].reload.collectivities_count }.from(1).to(0)
      .and change { subjects[1].reload.collectivities_count }.from(0).to(1)
  end

  it "doesn't change when updating territory of a discarded collectivity" do
    collectivity.discard
    expect { collectivity.update(territory: territories[1]) }
      .to  not_change { subjects[0].reload.collectivities_count }.from(0)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes when combining updating territory and discarding" do
    collectivity
    expect { collectivity.update(territory: territories[1], discarded_at: Time.current) }
      .to change { subjects[0].reload.collectivities_count }.from(1).to(0)
      .and not_change { subjects[1].reload.collectivities_count }.from(0)
  end

  it "changes when combining updating territory and undiscarding" do
    collectivity.discard
    expect { collectivity.update(territory: territories[1], discarded_at: nil) }
      .to  not_change { subjects[0].reload.collectivities_count }.from(0)
      .and change { subjects[1].reload.collectivities_count }.from(0).to(1)
  end
end
