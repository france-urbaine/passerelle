# frozen_string_literal: true

namespace :audits do
  desc "Insert missing audits (create & update)"
  task insert_missing: :environment do
    audits = []

    [
      Collectivity,
      Commune,
      Departement,
      DDFIP,
      DGFIP,
      EPCI,
      OauthAccessToken,
      OauthApplication,
      Office,
      OfficeCommune,
      OfficeUser,
      Package,
      Publisher,
      Region,
      Report,
      ReportExoneration,
      Transmission,
      User,
      Workshop
    ].each do |model|
      case model.name
      when "OauthApplication"
        model_attributes                   = %i[id created_at id]
        is_audit_with_oauth_application_id = true
      when "OauthAccessToken"
        model_attributes                   = %i[id created_at application_id]
        is_audit_with_oauth_application_id = true
      else
        model_attributes                   = %i[id created_at]
      end

      publisher_ids_map = OauthApplication.where(
        owner_type: "Publisher"
      ).pluck(
        :id,
        :owner_id
      ).to_h

      model.where(
        model.arel_table[:id].not_in(
          Audit.where(
            auditable_type: model.name,
            action: "create"
          ).pluck(:auditable_id)
        )
      ).pluck(*model_attributes).each do |record_attributes|
        record_id, record_created_at, = record_attributes

        audit = {
          auditable_id:         record_id,
          auditable_type:       model.name,
          associated_id:        nil,
          associated_type:      nil,
          oauth_application_id: nil,
          publisher_id:         nil,
          action:               "create",
          audited_changes:      {},
          created_at:           record_created_at,
          updated_at:           record_created_at
        }
        if is_audit_with_oauth_application_id
          audit[:associated_id]        = record_attributes.last
          audit[:associated_type]      = "OauthApplication"
          audit[:oauth_application_id] = record_attributes.last
          audit[:publisher_id]         = publisher_ids_map[record_attributes.last]
        end
        audits << audit
      end
    end

    Audit.insert_all(audits) unless audits.empty?
  end
end
