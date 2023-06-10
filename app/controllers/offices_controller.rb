# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action :authorize!
  before_action :load_and_authorize_parent
  before_action :autocompletion_not_implemented!, only: :index
  before_action :better_view_on_parent, only: :index

  def index
    @offices = build_and_authorize_scope
    @offices, @pagy = index_collection(@offices, nested: @parent)
  end

  def show
    @office = find_and_authorize_office
  end

  def new
    @office = build_office
    @background_url = referrer_path || parent_path || offices_path
  end

  def create
    @office = build_office(office_params)
    @office.save

    respond_with @office,
      flash: true,
      location: -> { redirect_path || parent_path || offices_path }
  end

  def edit
    @office = find_and_authorize_office
    @background_url = referrer_path || office_path(@office)
  end

  def update
    @office = find_and_authorize_office
    @office.update(office_params)

    respond_with @office,
      flash: true,
      location: -> { redirect_path || offices_path }
  end

  def remove
    @office = find_and_authorize_office
    @background_url = referrer_path || office_path(@office)
  end

  def destroy
    @office = find_and_authorize_office(allow_discarded: true)
    @office.discard

    respond_with @office,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || offices_path
  end

  def undiscard
    @office = find_and_authorize_office(allow_discarded: true)
    @office.undiscard

    respond_with @office,
      flash: true,
      location: redirect_path || referrer_path || offices_path
  end

  def remove_all
    @offices = build_and_authorize_scope
    @offices = filter_collection(@offices)

    @background_url = referrer_path || offices_path(**selection_params)
  end

  def destroy_all
    @offices = build_and_authorize_scope(as: :destroyable)
    @offices = filter_collection(@offices)
    @offices.quickly_discard_all

    respond_with @offices,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || offices_path
  end

  def undiscard_all
    @offices = build_and_authorize_scope(as: :undiscardable)
    @offices = filter_collection(@offices)
    @offices.quickly_undiscard_all

    respond_with @offices,
      flash: true,
      location: redirect_path || referrer_path || parent_path || offices_path
  end

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(Office.all, as:).strict_loading
  end

  def build_office(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_office(allow_discarded: false)
    office = Office.find(params[:id])

    authorize! office
    only_kept! office unless allow_discarded

    office
  end

  def office_params
    authorized(params.fetch(:office, {}))
      .then { |input| OfficeParamsParser.new(input, @parent).parse }
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
