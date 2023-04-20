# frozen_string_literal: true

class OfficesController < ApplicationController
  respond_to :html

  def index
    @offices = Office.kept.strict_loading
    @offices, @pagy = index_collection(@offices)

    respond_with @regions do |format|
      format.html.autocomplete { not_implemented }
    end
  end

  def show
    @office = Office.find(params[:id])
    gone if @office.discarded?
  end

  def new
    @office = Office.new(office_params)
    @background_url = referrer_path || offices_path
  end

  def edit
    @office = Office.find(params[:id])
    return gone if @office.discarded?

    @background_url = referrer_path || office_path(@office)
  end

  def remove
    @office = Office.find(params[:id])
    return gone if @office.discarded?

    @background_url = referrer_path || office_path(@office)
  end

  def remove_all
    @offices = Office.kept.strict_loading
    @offices = filter_collection(@offices)
    @background_url = referrer_path || offices_path(**selection_params)
  end

  def create
    @office = Office.new(office_params)
    @office.save

    respond_with @office,
      flash: true,
      location: -> { redirect_path || referrer_path || offices_path }
  end

  def update
    @office = Office.find(params[:id])
    return gone if @office.discarded?

    @office.update(office_params)

    respond_with @office,
      flash: true,
      location: -> { redirect_path || referrer_path || offices_path }
  end

  def destroy
    @office = Office.find(params[:id])
    @office.discard

    respond_with @office,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || offices_path
  end

  def undiscard
    @office = Office.find(params[:id])
    @office.undiscard

    respond_with @office,
      flash: true,
      location: redirect_path || referrer_path || offices_path
  end

  def destroy_all
    @offices = Office.kept.strict_loading
    @offices = filter_collection(@offices)
    @offices.dispose_all

    respond_with @offices,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || offices_path(**selection_params.except(:ids))
  end

  def undiscard_all
    @offices = Office.discarded.strict_loading
    @offices = filter_collection(@offices)
    @offices.undispose_all

    respond_with @offices,
      flash: true,
      location: redirect_path || offices_path
  end

  private

  def office_params
    input      = params.fetch(:office, {})
    ddfip_name = input.delete(:ddfip_name)

    input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id) if ddfip_name.present?

    input.permit(:ddfip_id, :name, :action)
  end
end
