# frozen_string_literal: true

class PackagesController < ApplicationController
  before_action :authorize!
  before_action :build_packages_scope
  before_action :authorize_packages_scope
  before_action :build_package,     only: %i[new create]
  before_action :find_package,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_package, only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @packages = @packages.kept.strict_loading
    @packages, @pagy = index_collection(@packages)
  end

  def show
    only_kept! @package
  end

  def new
    @background_url = referrer_path || parent_path || packages_path
  end

  def create
    @package.assign_attributes(package_params)
    @package.save

    respond_with @package,
      flash: true,
      location: -> { package_path(@package) }
  end

  def edit
    only_kept! @package
    @background_url = referrer_path || package_path(@package)
  end

  def update
    only_kept! @package
    @package.update(package_params)
    respond_with result,
      flash: true,
      location: -> { package_path(@package) }
  end

  private

  def build_packages_scope
    @packages = Package.all
  end

  def authorize_packages_scope
    @packages = authorized(@packages)
  end

  def build_package
    @package = @packages.build
  end

  def find_package
    @package = Package.find(params[:id])
  end

  def authorize_package
    authorize! @package
  end

  def package_params
    authorized(params.fetch(:package, {}))
  end

  def update_fields_param
    params.require(:fields)
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
