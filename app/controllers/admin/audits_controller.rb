# frozen_string_literal: true

module Admin
  class AuditsController < ApplicationController
    def index
      authorize!(:index?, with: Admin::AuditPolicy)
      load_and_authorize_resource
      load_audits
    end

    protected

    def authorized_audits_scope
      authorized_scope(
        load_and_authorize_resource.audits.descending,
        with: Admin::AuditPolicy
      )
    end

    def load_and_authorize_resource
      raise NotImplementedError
    end

    def load_audits
      if turbo_frame_request_id == "audits"
        @audits, @pagy = index_collection(authorized_audits_scope, nested: true)
      else
        @audits, @pagy = index_collection(authorized_audits_scope, items: 100)
      end
    end
  end
end
