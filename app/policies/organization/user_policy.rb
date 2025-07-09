# frozen_string_literal: true

module Organization
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, to: :show?
    alias_rule :new?, :create?, :edit?, :update?, to: :manage?
    alias_rule :remove?, to: :destroy?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def show?
      if record == User
        organization_admin? || supervisor?
      elsif record.is_a? User
        (organization_admin? && organization_match?(record)) ||
          (supervisor? && office_match?(record))
      end
    end

    def manage?
      if record == User
        organization_admin? || supervisor?
      elsif record.is_a? User
        organization_match?(record) && !record_as_more_privilege_than_current_user?(record) &&
          (organization_admin? || (supervisor? && office_match?(record)))
      end
    end

    def destroy?
      if supervisor? && !organization_admin? && record.is_a?(User)
        manage? &&
          record.office_ids.any? &&
          (record.office_ids - supervised_office_ids).empty?
      else
        manage?
      end
    end

    def reset?
      manage? && (
        (record == User) ||
        (record.is_a?(User) && user != record)
      )
    end

    relation_scope do |relation|
      if organization_admin?
        relation.kept.owned_by(organization)
      elsif supervisor?
        relation.kept.owned_by(organization).where(id: users_in_supervised_offices)
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation, exclude_current: true|
      relation = authorized(relation, with: self.class)
      relation = relation.where.not(id: user) if exclude_current

      relation = relation.where.not(id: users_in_unsupervised_offices) if supervisor?

      relation
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless organization_admin? || supervisor?

      attributes = %i[first_name last_name email]
      attributes << :super_admin if super_admin?
      attributes << :organization_admin if organization_admin?
      attributes << { office_users_attributes: %i[_destroy id office_id supervisor] } if organization.is_a?(DDFIP)

      if supervisor?
        params[:office_users_attributes]&.select! do |_index, office_user_params|
          office_user_params[:office_id]&.in?(supervised_office_ids)
        end
      end

      params.permit(*attributes)
    end

    private

    def users_in_supervised_offices
      ::User.owned_by(organization).joins(:office_users)
        .where("office_users.office_id": supervised_office_ids).distinct.select(:id)
    end

    def users_in_unsupervised_offices
      ::User.owned_by(organization).joins(:office_users)
        .where.not("office_users.office_id": supervised_office_ids).distinct.select(:id)
    end

    def office_match?(user)
      organization_match?(user) && user.office_ids.any? && user.office_ids.intersect?(supervised_office_ids)
    end

    def organization_match?(user)
      user.organization_type == organization.class.name &&
        user.organization_id == organization.id
    end

    def record_as_more_privilege_than_current_user?(other)
      other.super_admin? && !user.super_admin?
    end
  end
end
