# frozen_string_literal: true

RSpec.shared_context "when current user administrates the form_type" do
  let(:user_form_types) do
    build_stubbed(:user_form_type, user: current_user, form_type: report.form_type)
  end

  before do
    current_user.form_admin = true
    allow(current_user).to receive(:user_form_types).and_return([user_form_types])
  end
end

RSpec.shared_context "when current user administrates any other form_type" do
  let(:form_type) { (Report::FORM_TYPES - [report.form_type]).sample }

  let(:user_form_types) do
    build_stubbed(:user_form_type, user: current_user, form_type:)
  end

  before do
    current_user.form_admin = true
    allow(current_user).to receive(:user_form_types).and_return([user_form_types])
  end
end
