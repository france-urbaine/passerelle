# frozen_string_literal: true

module API
  class UploadController < ActiveStorage::DirectUploadsController
    before_action :doorkeeper_authorize!
    skip_forgery_protection
  end
end
