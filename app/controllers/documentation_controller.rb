# frozen_string_literal: true

class DocumentationController < ApplicationController
  respond_to :html

  before_action :validate_documentation_path

  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  prepend_view_path "app/views/documentation/api"

  layout "documentation"

  helper_method :documentation_partial

  def validate_documentation_path
    not_found unless lookup_context.exists?(documentation_partial, nil, true)
  end

  def documentation_partial
    @documentation_partial ||= begin
      partial = params[:id]
      partial || "guides/a_propos"
    end
  end
end
