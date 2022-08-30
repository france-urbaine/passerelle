# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  respond_to :html
  before_action :set_collectivity, only: %i[show edit update destroy]

  def index
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = search(@collectivities)
    @collectivities = order(@collectivities)
    @pagy, @collectivities = pagy(@collectivities)
  end

  def new
    @collectivity = Collectivity.new
  end

  def show; end
  def edit; end

  def create
    @collectivity = Collectivity.new(collectivity_params)

    if @collectivity.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :collectivities), notice: t(".success")
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collectivity.update(collectivity_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :collectivities), notice: t(".success")
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collectivity.discard

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to params.fetch(:back, :collectivities), notice: t(".success")
      end
    end
  end

  private

  def set_collectivity
    @collectivity = Collectivity.find(params[:id])
  end

  def collectivity_params
    params.fetch(:collectivity, {}).permit(
      :territory_type, :territory_id, :publisher_id,
      :name, :siren,
      :contact_first_name, :contact_last_name, :contact_email, :contact_phone
    )
  end
end
