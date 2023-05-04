# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficeUsersForm do
  subject(:form) do
    described_class.new(office)
  end

  let!(:office) { create(:office) }
  let!(:ddfip)  { office.ddfip }

  describe "#model_name" do
    it { is_expected.to respond_to(:model_name) }
    it { expect(form.model_name.param_key).to eq("office_users") }
  end

  describe "#user_ids" do
    it "returns IDs of all office users" do
      users = create_list(:user, 4, organization: ddfip)
      office.users = users[0..2]

      expect(form.user_ids)
        .to be_an(Array)
        .and have(3).items
        .and include(users[0].id, users[1].id, users[2].id)
        .and not_include(users[3].id)
    end
  end

  describe "#suggested_users" do
    it "returns a relation of users belonging to the DDFIP" do
      users  = create_list(:user, 2, organization: ddfip)
      users += create_list(:user, 2)

      expect(form.suggested_users)
        .to be_an(ActiveRecord::Relation)
        .and include(users[0], users[1])
        .and not_include(users[2], users[3])
    end
  end
end
