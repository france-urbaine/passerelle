# frozen_string_literal: true

class OrganizationsController < ApplicationController
  respond_to :html

  def index
    if autocomplete_request?
      @organizations = merge_autocomplete_collections(
        Publisher.kept.strict_loading,
        DDFIP.kept.strict_loading,
        Collectivity.kept.strict_loading
      )
    end

    respond_with @organizations do |format|
      format.html.autocomplete { render layout: false }
      format.html.any          { not_acceptable }
    end
  end
end
