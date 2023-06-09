# frozen_string_literal: true

RSpec.shared_context "with policies shared contexts" do
  let(:current_user)         { build_stubbed(:user) }
  let(:current_organization) { current_user&.organization }
  let(:context)              { { user: current_user } }

  shared_context "without current user" do
    let(:current_user) { nil }
  end

  {
    "a super admin"              => %i[super_admin],
    "an admin"                   => %i[organization_admin],
    "a DDFIP super admin"        => %i[ddfip super_admin],
    "a DDFIP admin"              => %i[ddfip organization_admin],
    "a DDFIP user"               => %i[ddfip],
    "a publisher super admin"    => %i[publisher super_admin],
    "a publisher admin"          => %i[publisher organization_admin],
    "a publisher user"           => %i[publisher],
    "a collectivity super admin" => %i[collectivity super_admin],
    "a collectivity admin"       => %i[collectivity organization_admin],
    "a collectivity user"        => %i[collectivity]
  }.each do |user_description, user_traits|
    shared_context "when current user is #{user_description}" do |**options|
      let(:current_user) do |example|
        options.each do |key, value|
          options[key] = instance_exec(&value) if value.respond_to?(:call)
        end

        if example.metadata[:stub_factories] == false
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
