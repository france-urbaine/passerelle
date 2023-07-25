# frozen_string_literal: true

module Offices
  class UpdateService < FormService
    alias_record :office

    attr_accessor :ddfip_name, :user_ids

    before_validation do
      apply_ddfip_name if ddfip_name
    end

    before_save do
      apply_user_ids if user_ids
    end

    private

    def apply_ddfip_name
      office.ddfip_id = DDFIP.kept.search(name: ddfip_name).pick(:id)
    end

    def apply_user_ids
      office.user_ids = office.ddfip.users.where(id: user_ids).pluck(:id)
    end
  end
end
