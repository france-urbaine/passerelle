# frozen_string_literal: true

module LinkHelper
  def authorized_link_to(resource, url = nil, scope: nil, **options, &)
    return if resource.nil?

    url ||= begin
      url_args = Array.wrap(scope) + [resource]
      url_for(url_args)
    end

    policy_options = options.extract!(:with)
    policy_options[:namespace] = nil if policy_options.empty?

    if allowed_to?(:show?, resource, **policy_options)
      link_to url, data: { turbo_frame: "_top" }, **options, &
    else
      capture(&)
    end
  end

  def short_offices_list(offices, ddfip_id, scope: nil)
    offices = offices.select { |office| office.kept? && office.ddfip_id == ddfip_id }
    return if offices.empty?

    # Add a consistent & deterministic order
    offices.sort_by(&:created_at)

    sort_list(offices) do |office|
      authorized_link_to(office, scope:) { office.name }
    end
  end

  def offices_list(offices, ddfip_id, scope: nil)
    offices = offices.select { |office| office.kept? && office.ddfip_id == ddfip_id }
    return if offices.empty?

    # Add a consistent & deterministic order
    offices.sort_by(&:created_at)

    list(offices) do |office|
      authorized_link_to(office, scope:) { office.name }
    end
  end
end
