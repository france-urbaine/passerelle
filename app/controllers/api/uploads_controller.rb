
module API
  class UploadsController < ActiveStorage::DirectUploadsController
    before_action :doorkeeper_authorize!
    skip_forgery_protection
  end
end