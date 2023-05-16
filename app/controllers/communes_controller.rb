# frozen_string_literal: true

class CommunesController < ApplicationController
  before_action do
    @communes_scope ||= Commune.all
  end

  def index
    return not_implemented if @parent && autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @communes = @communes_scope.strict_loading
    @communes, @pagy = index_collection(@communes, nested: @parent)

    respond_with @communes do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @commune = @communes_scope.find(params[:id])
  end

  def edit
    @commune = @communes_scope.find(params[:id])
    @background_url = referrer_path || commune_path(@commune)
  end

  def update
    @commune = @communes_scope.find(params[:id])
    @commune.update(commune_params)

    respond_with @commune,
      flash: true,
      location: -> { redirect_path || communes_path }
  end

  private

  def commune_params
    params
      .fetch(:commune, {})
      .permit(:name, :code_insee, :code_departement, :siren_epci, :qualified_name)
  end
end
