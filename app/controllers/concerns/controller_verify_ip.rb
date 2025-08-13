# frozen_string_literal: true

module ControllerVerifyIp
  class UnauthorizedIp < StandardError
    def initialize(controller, action)
      super("Unauthorized Ip for #{controller}##{action}")
    end
  end

  def verify_ip
    return unless current_organization.respond_to?(:ip_ranges) && current_organization.ip_ranges.any?

    raise UnauthorizedIp.new(controller_path, action_name) unless current_organization.ip_ranges.any? do |ip_range|
      IPAddr.new(ip_range).include?(request.remote_ip)
    end
  end
end
