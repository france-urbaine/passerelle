# frozen_string_literal: true

module PolicyTestHelpers
  module SharedUserContexts
    extend ActiveSupport::Concern

    included do
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
        "a DDFIP form admin"                 => %i[ddfip form_admin],
        "a DDFIP user"                       => %i[ddfip],
        "a DDFIP supervisor"                 => %i[ddfip supervisor],
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

      Report::FORM_TYPES.each do |form_type|
        shared_context "when current user is a DDFIP form admin for #{form_type}" do
          let(:current_user) do |example|
            if example.metadata[:stub_factories] == false
              create(:user, :form_admin, form_types: [form_type])
            else
              build_stubbed(:user, :form_admin, form_types: [form_type])
            end
          end
        end
      end
    end
  end
end
