# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
# rubocop:disable Style/SymbolProc

class Rack::Attack
  # https://github.com/rack/rack-attack/issues/145
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= ActionDispatch::Request.new(env).remote_ip
    end
  end

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:<Time.now.to_i/period>:requests/ip:<IP address>"
  #
  throttle("requests/ip", limit: 300, period: 5.minutes) do |request|
    request.remote_ip
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:<Time.now.to_i/period>:logins/ip:<IP address>"
  #
  throttle("logins/ip", limit: 5, period: 20.seconds) do |request|
    request.remote_ip if request.path == "/connexion" && request.post?
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  #
  # self.throttled_responder = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  ### Block pentesters

  # Block pentesting requests such as `/etc/password`, wordpress paths or SQL injections.
  # After 3 blocked requests in 10 minutes, block all requests from that IP for 1 day.
  #
  # Key: "rack::attack:fail2ban:ban:pentesters:<IP address>"
  #
  # To manually unban an IP :
  #   Rack::Attack.cache.delete("fail2ban:ban:pentesters:<IP address>")
  #
  blocklist("block pentesters") do |request|
    Rack::Attack::Fail2Ban.filter(
      "pentesters:#{request.remote_ip}",
      maxretry: 2,
      findtime: 10.minutes,
      bantime: 1.day
    ) do
      request.path.starts_with?("/wp") ||
        request.path.starts_with?("/wordpress") ||
        request.path.starts_with?("/cgi-bin") ||
        request.path.starts_with?("/etc/passwd") ||
        request.path.ends_with?(".env") ||
        request.path.ends_with?(".git/HEAD") ||
        request.path.ends_with?("license.txt") ||
        request.path.ends_with?("wlwmanifest.xml") ||
        request.fullpath.match?(/(.php|phpunit|phpMyAdmin)/) ||
        request.fullpath.include?(CGI.escape("/etc/passwd")) ||
        request.fullpath.include?(CGI.escape("select*from")) ||
        request.fullpath.match?(/%20(and|or|union)%20/)
    end
  end

  self.blocklisted_responder = lambda do |request|
    http_status = 404
    http_status = 403 if request.env["rack.attack.matched"] == "block pentesters"

    [http_status, { "Content-Type" => "text/plain" }, [""]]
  end
end

Rails.application.config.middleware.insert_after Rails::Rack::Logger, Rack::Attack

# rubocop:enable Style/ClassAndModuleChildren
# rubocop:enable Style/SymbolProc
