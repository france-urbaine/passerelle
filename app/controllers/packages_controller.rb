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

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(Package.preload(:reports).all, as:).strict_loading
  end

  def find_and_authorize_package(allow_discarded: false)
    package = Package.find(params[:id])

    authorize! package
    only_kept! package unless allow_discarded

    package
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
