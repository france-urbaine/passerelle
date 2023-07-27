# frozen_string_literal: true

class TerritoriesController < ApplicationController
  before_action :authorize!

  def index
    if autocomplete_request?
      @territories = merge_autocomplete_collections(
        Region.strict_loading,
        Departement.strict_loading,
        EPCI.strict_loading,
        Commune.strict_loading
      )
    end

    respond_with @territories do |format|
      format.html.autocomplete { render layout: false }
      format.html.any          { not_acceptable }
    end
  end

  protected

  def implicit_authorization_target
    :territories
  end
end
