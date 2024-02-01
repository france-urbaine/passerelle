# frozen_string_literal: true

RSpec.shared_context "when current user is member of targeted office" do
  include_context "when current user is a DDFIP user"

  let(:office) do
    build_stubbed(:office,
      ddfip:       record.ddfip,
      competences: [record.form_type],
      users:       [current_user])
  end

  before do
    allow(current_user).to receive(:offices).and_return([office])
    record.office = office
  end
end
