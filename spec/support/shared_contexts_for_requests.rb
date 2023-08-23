# frozen_string_literal: true

RSpec.shared_context "with requests shared contexts" do
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
    "super admin"              => %i[super_admin],
    "admin"                    => %i[organization_admin],
    "DDFIP super admin"        => %i[ddfip super_admin],
    "DDFIP admin"              => %i[ddfip organization_admin],
    "DDFIP user"               => %i[ddfip],
    "DGFIP super admin"        => %i[dgfip super_admin],
    "DGFIP admin"              => %i[dgfip organization_admin],
    "DGFIP user"               => %i[dgfip],
    "publisher super admin"    => %i[publisher super_admin],
    "publisher admin"          => %i[publisher organization_admin],
    "publisher user"           => %i[publisher],
    "collectivity super admin" => %i[collectivity super_admin],
    "collectivity admin"       => %i[collectivity organization_admin],
    "collectivity user"        => %i[collectivity]
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
