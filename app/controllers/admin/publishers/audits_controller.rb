# frozen_string_literal: true

module Admin
  module Publishers
    class AuditsController < ApplicationController
      def index
        authorize!(:index?, with: Admin::AuditPolicy)

        @publisher = Publisher.find(params[:publisher_id])
        authorize! @publisher

        if turbo_frame_request_id == "audits"
          @audits, @pagy = index_collection(authorized_audits_scope, nested: true)
        else
          @audits, @pagy = index_collection(authorized_audits_scope, items: 100)
        end
      end

      protected

      def authorized_audits_scope
        authorized_scope(
          @publisher.audits.descending,
          with: Admin::AuditPolicy
        )
      end
    end
  end
end
