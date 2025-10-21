# frozen_string_literal: true

RSpec.shared_context "when current user administrates the targeted form_type" do
  include_context "when current user is a DDFIP user"

  let(:user_form_types) do
    build_stubbed(:user_form_type, user: current_user, form_type: record.form_type)
  end

  before do
    allow(current_user).to receive(:user_form_types).and_return([user_form_types])
  end
end

RSpec.shared_context "when current user administrates another form_type" do
  include_context "when current user is a DDFIP user"

  let(:form_type) { (Report::FORM_TYPES - [record.form_type]).sample }

  let(:user_form_types) do
    build_stubbed(:user_form_type, user: current_user, form_type:)
  end

  before do
    allow(current_user).to receive(:user_form_types).and_return([user_form_types])
  end
end
