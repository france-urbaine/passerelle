# frozen_string_literal: true

require "net/http"

module XLSXParser
  module_function

  def call(path, sheet, offset: 0)
    return to_enum(__callee__, path, sheet, offset:) unless block_given?

    path    = Rails.root.join(path).to_s
    xlsx    = Roo::Spreadsheet.open(path)
    headers = xlsx.each_row_streaming(sheet:, offset:).peek.map(&:to_s)

    xlsx.each_row_streaming(sheet:, offset: offset + 1) do |row|
      row = row.map(&:to_s)
      row = headers.zip(row).to_h
      yield row
    end
  ensure
    xlsx&.close
  end
end
