# frozen_string_literal: true

RSpec.shared_context "with requests shared contexts" do
  shared_context "when requesting HTML" do
    let(:as) { :html }
  end

  shared_context "when requesting JSON" do
    let(:as) { :json }
  end

  # rubocop:disable RSpec/LetSetup
  #
  # This shared context accepts traits, raw and proc attributes:
  # Example:
  #
  #   it_behaves_like "when signed in", email: "foo@bar.com"
  #   it_behaves_like "when signed in", :organization_admin, organisation: ->{ record.organization  }
  #
  shared_context "when signed in" do |*traits, **attributes|
    let!(:current_user) do
      attributes.transform_values! { |value| value.respond_to?(:call) ? instance_exec(&value) : value }

      user = create(:user, *traits, **attributes)
      sign_in(user)
      user
    end
  end

  {
    "publisher user"    => %i[publisher],
    "publisher admin"   => %i[publisher organization_admin],
    "DDFIP user"        => %i[ddfip],
    "DDFIP admin"       => %i[ddfip organization_admin],
    "colletivity user"  => %i[collectivity],
    "colletivity admin" => %i[collectivity organization_admin],
    "super admin"       => %i[super_admin]
  }.each do |user_description, user_traits|
    # These shared contexts accepts literal and proc attributes:
    # See `shared_context "when signed in"` for more info.
    #
    shared_context "when signed in as #{user_description}" do |**options|
      include_context "when signed in", *user_traits, **options
    end
  end
  #
  # rubocop:enable RSpec/LetSetup
end

RSpec.configure do |rspec|
  rspec.include_context "with requests shared contexts", type: :request
end
