# frozen_string_literal: true

module LinkHelper
  def authorized_link_to(resource, url = nil, scope: nil, **options, &)
    return if resource.nil?

    url ||= begin
      url_args = Array.wrap(scope) + [resource]
      url_for(url_args)
    end

    policy_options = options.extract!(:with, :namespace)
    policy_options[:namespace] ||= scope&.to_s&.camelize&.safe_constantize

    if allowed_to?(:show?, resource, **policy_options)
      link_to url, data: { turbo_frame: "_top" }, **options, &
    else
      capture(&)
    end
  end
end
