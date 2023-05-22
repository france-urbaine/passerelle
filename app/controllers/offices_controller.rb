# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action :scope_offices
  before_action :build_office, only: %i[new create]
  before_action :find_office,  only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @offices = @offices.kept.strict_loading
    @offices, @pagy = index_collection(@offices, nested: @parent)
  end

  def show
    only_kept! @office
  end

  def new
    @background_url = referrer_path || parent_path || offices_path
  end

  def edit
    only_kept! @office
    @background_url = referrer_path || office_path(@office)
  end

  def remove
    only_kept! @office
    @background_url = referrer_path || office_path(@office)
  end

  def remove_all
    @offices = @offices.kept.strict_loading
    @offices = filter_collection(@offices)

    @background_url = referrer_path || offices_path(**selection_params)
  end

  def create
    @office.assign_attributes(office_params)
    @office.save

    respond_with @office,
      flash: true,
      location: -> { redirect_path || parent_path || offices_path }
  end

  def update
    only_kept! @office
    @office.update(office_params)

    respond_with @office,
      flash: true,
      location: -> { redirect_path || offices_path }
  end

  def destroy
    @office.discard

    respond_with @office,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || offices_path
  end

  def undiscard
    @office.undiscard

    respond_with @office,
      flash: true,
      location: redirect_path || referrer_path || offices_path
  end

  def destroy_all
    @offices = @offices.kept.strict_loading
    @offices = filter_collection(@offices)
    @offices.quickly_discard_all

    respond_with @offices,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || offices_path
  end

  def undiscard_all
    @offices = @offices.discarded.strict_loading
    @offices = filter_collection(@offices)
    @offices.quickly_undiscard_all

    respond_with @offices,
      flash: true,
      location: redirect_path || referrer_path || parent_path || offices_path
  end

  private

  def parent_path
    url_for(@parent) if @parent
  end

  def scope_offices
    @offices = Office.all
  end

  def build_office
    @office = @offices.build
  end

  def find_office
    @office = @offices.find(params[:id])
  end

  def office_params
    input      = params.fetch(:office, {})
    ddfip_name = input.delete(:ddfip_name)

    input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id) if ddfip_name.present?

    input.permit(:ddfip_id, :name, :action)
  end
end
