# frozen_string_literal: true

# This file is excluded from coverage reports.
# We'll have to remove the :nocov: tag when we'll start using ApplicationCable
#
# :nocov:
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end
# :nocov:
