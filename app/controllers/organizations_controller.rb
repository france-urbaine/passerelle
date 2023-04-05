# frozen_string_literal: true

class OrganizationsController < ApplicationController
  respond_to :html

  def index
    if autocomplete_request?
      @organizations  = autocomplete_organizations(Publisher)
      @organizations += autocomplete_organizations(DDFIP, @organizations)
      @organizations += autocomplete_organizations(Collectivity, @organizations)
    end

    respond_to do |format|
      format.html.autocomplete { render layout: false }
      format.html.any          { not_acceptable }
    end
  end

  protected

  def autocomplete_organizations(model, organizations = [])
    return organizations if organizations.size >= 50

    relation = model.strict_loading.kept
    relation = search_collection(relation)
    relation = order_collection(relation)
    relation = relation.limit(50 - organizations.size)
    relation.to_a
  end
end
