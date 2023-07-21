# frozen_string_literal: true

module Offices
  class UpdateService < FormService
    alias_record :office

    attr_accessor :ddfip_name

    before_validation do
      apply_ddfip_name if ddfip_name
    end

    private

    def apply_ddfip_name
      office.ddfip_id = DDFIP.kept.search(name: ddfip_name).pick(:id)
    end
  end
end
