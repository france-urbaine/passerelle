# frozen_string_literal: true

class PackagesController < ApplicationController
  before_action :authorize!
  before_action :load_and_authorize_parent
  before_action :autocompletion_not_implemented!, only: :index
  before_action :better_view_on_parent, only: :index

  def index
    @packages = build_and_authorize_scope
    @packages, @pagy = index_collection(@packages)
  end

  def show
    @package = find_and_authorize_package
  end

  def new
    @package = build_package
    @referrer_path = referrer_path || parent_path || packages_path
  end

  def create
    @package = build_package(package_params)
    @package.save

    respond_with @package,
      flash: true,
      location: -> { package_path(@package) }
  end

  def edit
    @package = find_and_authorize_package
    @referrer_path = referrer_path || package_path(@package)
  end

  def update
    @package = find_and_authorize_package
    @package.update(package_params)

    respond_with @package,
      flash: true,
      location: -> { redirect_path || package_path(@package) }
  end

  def remove
    @package = find_and_authorize_package
    @referrer_path = referrer_path || package_path(@package)
  end

  def destroy
    @package = find_and_authorize_package(allow_discarded: true)
    @package.discard

    respond_with @package,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || packages_path
  end

  def undiscard
    @package = find_and_authorize_package(allow_discarded: true)
    @package.undiscard

    respond_with @package,
      flash: true,
      location: redirect_path || referrer_path || packages_path
  end

  def remove_all
    @packages = build_and_authorize_scope(as: :destroyable)
    @packages = filter_collection(@packages)
    @referrer_path = referrer_path || packages_path(**selection_params)
  end

  def destroy_all
    @packages = build_and_authorize_scope(as: :destroyable)
    @packages = filter_collection(@packages)
    @packages.quickly_discard_all

    respond_with @packages,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || packages_path
  end

  def undiscard_all
    @packages = build_and_authorize_scope(as: :undiscardable)
    @packages = filter_collection(@packages)
    @packages.quickly_undiscard_all

    respond_with @packages,
      flash: true,
      location: redirect_path || referrer_path || parent_path || packages_path
  end

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(Package.all, as:).strict_loading
  end

  def build_package(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_package(allow_discarded: false)
    package = Package.find(params[:id])

    authorize! package
    only_kept! package unless allow_discarded

    package
  end

  def package_params
    authorized(params.fetch(:package, {}))
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
