# frozen_string_literal: true

class PublishersController < ApplicationController
  before_action :authorize!
  before_action :autocompletion_not_implemented!, only: :index

  def index
    @publishers = build_and_authorize_scope
    @publishers, @pagy = index_collection(@publishers)
  end

  def show
    @publisher = find_and_authorize_publisher
  end

  def new
    @publisher = build_publisher
    @referrer_path = referrer_path || publishers_path
  end

  def create
    @publisher = build_publisher(publisher_params)
    @publisher.save

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def edit
    @publisher = find_and_authorize_publisher
    @referrer_path = referrer_path || publisher_path(@publisher)
  end

  def update
    @publisher = find_and_authorize_publisher
    @publisher.update(publisher_params)

    respond_with @publisher,
      flash: true,
      location: -> { redirect_path || publishers_path }
  end

  def remove
    @publisher = find_and_authorize_publisher
    @referrer_path = referrer_path || publisher_path(@publisher)
  end

  def destroy
    @publisher = find_and_authorize_publisher(allow_discarded: true)
    @publisher.discard

    respond_with @publisher,
      flash: true,
      actions: undiscard_publisher_action(@publisher),
      location: redirect_path || publishers_path
  end

  def undiscard
    @publisher = find_and_authorize_publisher(allow_discarded: true)
    @publisher.undiscard

    respond_with @publisher,
      flash: true,
      location: redirect_path || referrer_path || publishers_path
  end

  def remove_all
    @publishers = build_and_authorize_scope
    @publishers = filter_collection(@publishers)
    @referrer_path = referrer_path || publishers_path(**selection_params)
  end

  def destroy_all
    @publishers = build_and_authorize_scope(as: :destroyable)
    @publishers = filter_collection(@publishers)
    @publishers.quickly_discard_all

    respond_with @publishers,
      flash: true,
      actions: undiscard_all_publishers_action,
      location: redirect_path || publishers_path
  end

  def undiscard_all
    @publishers = build_and_authorize_scope(as: :undiscardable)
    @publishers = filter_collection(@publishers)
    @publishers.quickly_undiscard_all

    respond_with @publishers,
      flash: true,
      location: redirect_path || referrer_path || publishers_path
  end

  private

  def build_and_authorize_scope(as: :default)
    authorized(Publisher.all, as:).strict_loading
  end

  def build_publisher(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_publisher(allow_discarded: false)
    publisher = Publisher.find(params[:id])

    authorize! publisher
    only_kept! publisher unless allow_discarded

    publisher
  end

  def publisher_params
    authorized(params.fetch(:publisher, {}))
  end
end
