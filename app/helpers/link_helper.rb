# frozen_string_literal: true

module LinkHelper
  def authorized_link_to(resource, url = nil, **options, &)
    url ||= url_for(resource)

    policy_options = options.extract!(:with)
    policy_options[:namespace] = nil if policy_options.empty?

    if allowed_to?(:show?, resource, **policy_options)
      link_to url, data: { turbo_frame: "_top" }, **options, &
    else
      capture(&)
    end
  end
end
