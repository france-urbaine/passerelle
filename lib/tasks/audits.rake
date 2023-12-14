# frozen_string_literal: true

namespace :audits do
  desc "Insert missing audits (create & update)"
  task insert_missing: :environment do
    oauth_application_audits  = []
    oauth_access_token_audits = []
    transmission_audits       = []
    other_audits              = []

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
        model_attributes                = %i[id created_at updated_at id]
        audit_with_oauth_application_id = true
        audits_array                    = oauth_application_audits
      when "OauthAccessToken"
        model_attributes                = %i[id created_at created_at application_id]
        audit_with_oauth_application_id = true
        audits_array                    = oauth_access_token_audits
        skip_update_audit               = true
      when "Transmission"
        model_attributes                = %i[id created_at updated_at oauth_application_id]
        audit_with_oauth_application_id = true
        audits_array                    = transmission_audits
      else
        model_attributes                = %i[id created_at updated_at]
        audits_array                    = other_audits
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
        record_id, record_created_at, record_updated_at, = record_attributes

        audit = {
          auditable_id: record_id,
          auditable_type: model.name,
          action: "create",
          audited_changes: {},
          created_at: record_created_at,
          updated_at: record_created_at
        }
        if audit_with_oauth_application_id
          audit[:associated_id]        = record_attributes.last
          audit[:associated_type]      = "OauthApplication"
          audit[:oauth_application_id] = record_attributes.last
          audit[:publisher_id]         = publisher_ids_map[record_attributes.last]
        end
        audits_array << audit

        next if record_updated_at == record_created_at || skip_update_audit

        audit = {
          auditable_id: record_id,
          auditable_type: model.name,
          action: "update",
          audited_changes: {},
          created_at: record_updated_at,
          updated_at: record_updated_at
        }
        if audit_with_oauth_application_id
          audit[:associated_id]        = record_attributes.last
          audit[:associated_type]      = "OauthApplication"
          audit[:oauth_application_id] = record_attributes.last
          audit[:publisher_id]         = publisher_ids_map[record_attributes.last]
        end
        audits_array << audit
      end
    end

    Audit.insert_all(oauth_application_audits)  unless oauth_application_audits.empty?
    Audit.insert_all(oauth_access_token_audits) unless oauth_access_token_audits.empty?
    Audit.insert_all(transmission_audits)       unless transmission_audits.empty?
    Audit.insert_all(other_audits)              unless other_audits.empty?
  end
end
