# frozen_string_literal: true

RSpec.shared_context "with user context in policies" do
  let(:current_user)         { build_stubbed(:user) }
  let(:current_organization) { current_user&.organization }
  let(:context)              { { user: current_user } }

  shared_context "without current user" do
    let(:current_user) { nil }
  end

  {
    "a super admin"                      => %i[super_admin],
    "an admin"                           => %i[organization_admin],
    "a DDFIP admin & super admin"        => %i[ddfip super_admin organization_admin],
    "a DDFIP super admin"                => %i[ddfip super_admin],
    "a DDFIP admin"                      => %i[ddfip organization_admin],
    "a DDFIP user"                       => %i[ddfip],
    "a DGFIP admin & super admin"        => %i[dgfip super_admin organization_admin],
    "a DGFIP super admin"                => %i[dgfip super_admin],
    "a DGFIP admin"                      => %i[dgfip organization_admin],
    "a DGFIP user"                       => %i[dgfip],
    "a publisher admin & super admin"    => %i[publisher super_admin organization_admin],
    "a publisher super admin"            => %i[publisher super_admin],
    "a publisher admin"                  => %i[publisher organization_admin],
    "a publisher user"                   => %i[publisher],
    "a collectivity admin & super admin" => %i[collectivity super_admin organization_admin],
    "a collectivity super admin"         => %i[collectivity super_admin],
    "a collectivity admin"               => %i[collectivity organization_admin],
    "a collectivity user"                => %i[collectivity]
  }.each do |user_description, user_traits|
    shared_context "when current user is #{user_description}" do
      let(:current_user) do |example|
        if example.metadata[:stub_factories] == false
          create(:user, *user_traits)
        else
          build_stubbed(:user, *user_traits)
        end
      end
    end
  end
end

RSpec.shared_context "with policies scopes helpers" do
  let(:scope_options) { |e| e.metadata.fetch(:scope_options, {}) }

  def apply_params_scope(params, type: :action_controller_params, **)
    params = ActionController::Parameters.new(params)
    params = policy.apply_scope(params, type:, **)
    params&.to_hash&.symbolize_keys
  end

  def apply_relation_scope(target, type: :active_record_relation, **)
    policy.apply_scope(target, type:, scope_options:, **)
  end
end

RSpec.configure do |config|
  config.include_context "with user context in policies", type: :policy
  config.include_context "with policies scopes helpers",  type: :policy
end
