# frozen_string_literal: true

require "zip"

module Unarchiver
  module_function

  def call(path, file_catch = "*")
    path   = Rails.root.join(path)
    target = nil

    Zip::File.open(path.to_s) do |zip_file|
      entry = zip_file.glob(file_catch).first

      target = path.dirname.join(entry.name)
      target.dirname.mkpath
      target.delete if target.exist?

      entry.extract(target.to_s)
    end

    target
  end
end
