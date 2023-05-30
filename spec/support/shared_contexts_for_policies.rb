# frozen_string_literal: true

RSpec.shared_context "with policies shared contexts" do
  let(:current_user)         { build_stubbed(:user) }
  let(:current_organization) { current_user&.organization }
  let(:context)              { { user: current_user } }

  shared_context "without current user" do
    let(:current_user) { nil }
  end

  {
    "publisher user"     => %i[publisher],
    "publisher admin"    => %i[publisher organization_admin],
    "DDFIP user"         => %i[ddfip],
    "DDFIP admin"        => %i[ddfip organization_admin],
    "collectivity user"  => %i[collectivity],
    "collectivity admin" => %i[collectivity organization_admin],
    "super admin"        => %i[super_admin]
  }.each do |user_description, user_traits|
    shared_context "when current user is a #{user_description}" do |**options|
      let(:current_user) do |example|
        options.each do |key, value|
          options[key] = instance_exec(&value) if value.respond_to?(:call)
        end

        if example.metadata[:stub_current_user] == false
          create(:user, *user_traits, **options)
        else
          build_stubbed(:user, *user_traits, **options)
        end
      end
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with policies shared contexts", type: :policy
end
