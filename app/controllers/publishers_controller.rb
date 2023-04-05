# frozen_string_literal: true

class PublishersController < ApplicationController
  respond_to :html

  before_action :set_publisher,              only: %i[show edit update remove destroy undiscard]
  before_action :set_background_content_url, only: %i[new edit remove]

  def index
    @publishers = Publisher.kept.strict_loading
    @publishers, @pagy = index_collection(@publishers)
  end

  def show; end

  def new
    @publisher = Publisher.new
  end

  def edit; end
  def remove; end

  def create
    @publisher = Publisher.new(publisher_params)

    if @publisher.save
      @location = publisher_path(@publisher)
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
      @location = url_from(params[:redirect]) || publishers_path
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

    @location = url_from(params[:redirect]) || publishers_path
    @notice   = translate(".success")
    @cancel   = FlashAction::Cancel.new(params).to_session

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html         { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def remove_all
    @publishers = Publisher.kept.strict_loading
    @publishers = filter_collection(@publishers)

    @background_content_url = publishers_path(ids: params[:ids], **index_params)
    @return_location        = publishers_path(**index_params)
  end

  def destroy_all
    @publishers = Publisher.kept.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.update_all(discarded_at: Time.current)

    @location   = publishers_path if params[:ids] == "all"
    @location ||= publishers_path(**index_params)
    @notice     = translate(".success")
    @cancel     = FlashAction::Cancel.new(params).to_session

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html          { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def undiscard
    @publisher.undiscard

    @location = url_from(params[:redirect]) || publishers_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @publishers = Publisher.discarded.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.update_all(discarded_at: nil)

    @location = url_from(params[:redirect]) || publishers_path
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

  def set_background_content_url
    default = publishers_path
    default = publisher_path(@publisher) if @publisher&.persisted?

    @background_content_url = url_from(params[:content]) || default
  end

  def publisher_params
    params
      .fetch(:publisher, {})
      .permit(:name, :siren, :email)
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
