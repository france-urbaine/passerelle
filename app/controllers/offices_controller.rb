# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action do
    @offices_scope ||= Office.all
  end

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @offices = @offices_scope.kept.strict_loading
    @offices, @pagy = index_collection(@offices, nested: @parent)
  end

  def show
    @office = @offices_scope.find(params[:id])
    gone(@office) if @office.discarded?
  end

  def new
    @office = @offices_scope.new(office_params)
    @background_url = referrer_path || parent_path || offices_path
  end

  def edit
    @office = @offices_scope.find(params[:id])
    return gone(@office) if @office.discarded?

    @background_url = referrer_path || office_path(@office)
  end

  def remove
    @office = @offices_scope.find(params[:id])
    return gone(@office) if @office.discarded?

    @background_url = referrer_path || office_path(@office)
  end

  def remove_all
    @offices = @offices_scope.kept.strict_loading
    @offices = filter_collection(@offices)
    @background_url = referrer_path || offices_path(**selection_params)
  end

  def create
    @office = @offices_scope.new(office_params)
    @office.save

    respond_with @office,
      flash: true,
      location: -> { redirect_path || parent_path || offices_path }
  end

  def update
    @office = @offices_scope.find(params[:id])
    return gone(@office) if @office.discarded?

    @office.update(office_params)

    respond_with @office,
      flash: true,
      location: -> { redirect_path || offices_path }
  end

  def destroy
    @office = @offices_scope.find(params[:id])
    @office.discard

    respond_with @office,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || offices_path
  end

  def undiscard
    @office = @offices_scope.find(params[:id])
    @office.undiscard

    respond_with @office,
      flash: true,
      location: redirect_path || referrer_path || offices_path
  end

  def destroy_all
    @offices = @offices_scope.kept.strict_loading
    @offices = filter_collection(@offices)
    @offices.quickly_discard_all

    respond_with @offices,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || offices_path
  end

  def undiscard_all
    @offices = @offices_scope.discarded.strict_loading
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

  def office_params
    input      = params.fetch(:office, {})
    ddfip_name = input.delete(:ddfip_name)

    input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id) if ddfip_name.present?

    input.permit(:ddfip_id, :name, :action)
  end
end
