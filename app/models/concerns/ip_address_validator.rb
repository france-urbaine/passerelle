# frozen_string_literal: true

class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Array.wrap(value).each do |ip|
      IPAddr.new(ip)
    rescue IPAddr::InvalidAddressError
      record.errors.add(attribute, :invalid_ip_address, ip:)
    end
  end
end
