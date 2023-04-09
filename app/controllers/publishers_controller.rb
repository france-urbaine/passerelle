# frozen_string_literal: true

class PublishersController < ApplicationController
  respond_to :html

  def index
    @publishers = Publisher.kept.strict_loading
    @publishers, @pagy = index_collection(@publishers)

    respond_with @publishers do |format|
      format.html.autocomplete { not_implemented }
    end
  end

  def show
    @publisher = Publisher.find(params[:id])
  end

  def new
    @publisher = Publisher.new(publisher_params)
    @background_url = referrer_path || publishers_path
  end

  def edit
    @publisher = Publisher.find(params[:id])
    @background_url = referrer_path || publisher_path(@publisher)
  end

  def remove
    @publisher = Publisher.find(params[:id])
    @background_url = referrer_path || publisher_path(@publisher)
  end

  def remove_all
    @publishers = Publisher.kept.strict_loading
    @publishers = filter_collection(@publishers)
    @background_url = referrer_path || publishers_path(**selection_params)
  end

  def create
    @publisher = Publisher.new(publisher_params)
    @publisher.save

    @background_url = referrer_path || publishers_path if @publisher.errors.any?

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def update
    @publisher = Publisher.find(params[:id])
    @publisher.update(publisher_params)

    @background_url = referrer_path || publisher_path(@publisher) if @publisher.errors.any?

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def destroy
    @publisher = Publisher.find(params[:id])
    @publisher.discard

    respond_with @publisher,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || publishers_path
  end

  def undiscard
    @publisher = Publisher.find(params[:id])
    @publisher.undiscard

    respond_with @publisher,
      flash: true,
      location: redirect_path || publishers_path
  end

  def destroy_all
    @publishers = Publisher.kept.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.dispose_all

    respond_with @publishers,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || publishers_path(**selection_params.except(:ids))
  end

  def undiscard_all
    @publishers = Publisher.discarded.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.undispose_all

    respond_with @publishers,
      flash: true,
      location: redirect_path || publishers_path
  end

  private

  def publisher_params
    params
      .fetch(:publisher, {})
      .permit(:name, :siren, :email)
  end
end
