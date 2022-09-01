# frozen_string_literal: true

class PublishersController < ApplicationController
  respond_to :html
  before_action :set_publisher, only: %i[show edit update destroy]

  def index
    @publishers = Publisher.kept.strict_loading
    @publishers = search(@publishers)
    @publishers = order(@publishers)
    @pagy, @publishers = pagy(@publishers)
  end

  def new
    @publisher = Publisher.new
  end

  def show; end
  def edit; end

  def create
    @publisher = Publisher.new(publisher_params)

    if @publisher.save
      @notice   = t(".success")
      @location = params.fetch(:form_back, publishers_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @publisher.update(publisher_params)
      @notice   = t(".success")
      @location = params.fetch(:form_back, publishers_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @publisher.discard

    @notice   = t(".success")
    @location = params.fetch(:form_back, publishers_path)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_publisher
    @publisher = Publisher.find(params[:id])
  end

  def publisher_params
    params.fetch(:publisher, {})
          .permit(:name, :siren, :email)
  end
end
