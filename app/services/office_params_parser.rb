# frozen_string_literal: true

# OfficeParamsParser is a service to parse parameters passed to
# OfficesController to create or update an office.
#
class OfficeParamsParser
  def initialize(input, ddfip = nil)
    @input = input.dup
    @ddfip = ddfip
  end

  def parse
    if @ddfip
      @input.delete(:ddfip_id)
      @input.delete(:ddfip_name)
    end

    parse_ddfip_name
    @input
  end

  protected

  def parse_ddfip_name
    ddfip_name = @input.delete(:ddfip_name)
    return if ddfip_name.blank?

    @input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id)
  end
end
