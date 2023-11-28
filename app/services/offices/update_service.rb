# frozen_string_literal: true

module Offices
  class UpdateService < FormService
    alias_record :office

    attr_accessor :ddfip_name, :user_ids, :commune_ids

    before_validation do
      apply_ddfip_name if ddfip_name
    end

    before_save do
      apply_user_ids if user_ids
      apply_commune_ids if commune_ids
    end

    private

    def apply_ddfip_name
      office.ddfip_id = DDFIP.kept.search(name: ddfip_name).pick(:id)
    end

    def apply_user_ids
      office.user_ids = office.ddfip.users.where(id: user_ids).pluck(:id)
    end

    def apply_commune_ids
      # Using `office.commune_ids=` could be slow because ActiveRecord
      # performs one query per communes to insert
      #
      previous_commune_ids = office.commune_ids
      new_commune_ids      = office.assignable_communes
        .where(code_insee: commune_ids)
        .pluck(:code_insee)

      delete_commune_ids(previous_commune_ids - new_commune_ids)
      insert_commune_codes(new_commune_ids - previous_commune_ids)
    end

    def delete_commune_ids(codes)
      return if codes.empty?

      OfficeCommune.where(office_id: office.id, code_insee: codes).delete_all
    end

    def insert_commune_codes(codes)
      return if codes.empty?

      input = codes.map do |value|
        { office_id: office.id, code_insee: value }
      end

      OfficeCommune.insert_all(input)
    end
  end
end
