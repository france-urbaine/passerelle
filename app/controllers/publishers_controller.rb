# frozen_string_literal: true

class PublishersController < ApplicationController
  before_action :authorize!
  before_action :build_publishers_scope
  before_action :authorize_publishers_scope
  before_action :build_publisher,     only: %i[new create]
  before_action :find_publisher,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_publisher, only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?

    @publishers = @publishers.kept.strict_loading
    @publishers, @pagy = index_collection(@publishers)
  end

  def show
    only_kept! @publisher
  end

  def new
    @background_url = referrer_path || publishers_path
  end

  def create
    @publisher.assign_attributes(publisher_params)
    @publisher.save

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def edit
    only_kept! @publisher
    @background_url = referrer_path || publisher_path(@publisher)
  end

  def update
    only_kept! @publisher
    @publisher.update(publisher_params)

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def remove
    only_kept! @publisher
    @background_url = referrer_path || publisher_path(@publisher)
  end

  def destroy
    @publisher.discard

    respond_with @publisher,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || publishers_path
  end

  def undiscard
    @publisher.undiscard

    respond_with @publisher,
      flash: true,
      location: redirect_path || referrer_path || publishers_path
  end

  def remove_all
    @publishers = @publishers.kept.strict_loading
    @publishers = filter_collection(@publishers)

    @background_url = referrer_path || publishers_path(**selection_params)
  end

  def destroy_all
    @publishers = @publishers.kept.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.quickly_discard_all

    respond_with @publishers,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || publishers_path
  end

  def undiscard_all
    @publishers = @publishers.discarded.strict_loading
    @publishers = filter_collection(@publishers)
    @publishers.quickly_undiscard_all

    respond_with @publishers,
      flash: true,
      location: redirect_path || referrer_path || publishers_path
  end

  private

  def build_publishers_scope
    @publishers = Publisher.all
  end

  def authorize_publishers_scope
    @publishers = authorized(@publishers)
  end

  def build_publisher
    @publisher = @publishers.build
  end

  def find_publisher
    @publisher = Publisher.find(params[:id])
  end

  def authorize_publisher
    authorize! @publisher
  end

  def publisher_params
    authorized(params.fetch(:publisher, {}))
  end
end
