# frozen_string_literal: true

class PublishersController < ApplicationController
  respond_to :html

  before_action :set_publisher,        only: %i[show edit update remove destroy undiscard]
  before_action :set_content_location, only: %i[new edit remove]

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
  def remove; end

  def create
    @publisher = Publisher.new(publisher_params)

    if @publisher.save
      @location = safe_location_param(:redirect, publishers_path)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @publisher.update(publisher_params)
      @location = safe_location_param(:redirect, publishers_path)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @publisher.discard

    @location = safe_location_param(:redirect, publishers_path)
    @notice   = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_publisher_path(@publisher),
        method: :patch,
        inputs: { redirect: @location }
      }
    )

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def remove_all
    @publishers = Publisher.kept.strict_loading
    @publishers = search(@publishers)
    @publishers = select(@publishers)

    @content_location = publishers_path(ids: params[:ids], **index_params)
    @return_location  = publishers_path(**index_params)
  end

  def destroy_all
    @publishers = Publisher.kept.strict_loading
    @publishers = search(@publishers)
    @publishers = select(@publishers)
    @publishers.update_all(discarded_at: Time.current)

    @location   = publishers_path if params[:ids] == "all"
    @location ||= publishers_path(**index_params)
    @notice     = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_all_publishers_path,
        method: :patch,
        inputs: {
          ids:      params[:ids],
          redirect: @location,
          **index_params
        }
      }
    )

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice }
      format.html          { redirect_to @location, notice: @notice }
    end
  end

  def undiscard
    @publisher.undiscard

    @location = safe_location_param(:redirect, publishers_path)
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @publishers = Publisher.discarded.strict_loading
    @publishers = search(@publishers)
    @publishers = select(@publishers)
    @publishers.update_all(discarded_at: nil)

    @location = safe_location_param(:redirect, publishers_path)
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_publisher
    @publisher = Publisher.find(params[:id])
  end

  def set_content_location
    default = publishers_path
    default = publisher_path(@publisher) if @publisher&.persisted?

    @content_location = safe_location_param(:content, default)
  end

  def publisher_params
    params.fetch(:publisher, {})
          .permit(:name, :siren, :email)
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
