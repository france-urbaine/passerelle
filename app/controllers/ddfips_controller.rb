# frozen_string_literal: true

class DdfipsController < ApplicationController
  respond_to :html
  before_action :set_ddfip, only: %i[show edit update destroy]

  def index
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = search(@ddfips)
    @ddfips = order(@ddfips)
    @pagy, @ddfips = pagy(@ddfips)
  end

  def new
    @ddfip = DDFIP.new
  end

  def show; end
  def edit; end

  def create
    @ddfip = DDFIP.new(ddfip_params)

    if @ddfip.save
      @notice   = t(".success")
      @location = params.fetch(:form_back, ddfips_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @ddfip.update(ddfip_params)
      @notice   = t(".success")
      @location = params.fetch(:form_back, ddfips_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ddfip.discard

    @notice   = t(".success")
    @location = params.fetch(:form_back, ddfips_path)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_ddfip
    @ddfip = DDFIP.find(params[:id])
  end

  def ddfip_params
    params.fetch(:ddfip, {})
          .permit(:name, :code_departement)
  end
end
