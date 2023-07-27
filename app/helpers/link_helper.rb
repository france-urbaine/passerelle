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

  def short_offices_list(offices, ddfip_id, scope: nil)
    offices = offices.select { |office| office.kept? && office.ddfip_id == ddfip_id }
    return if offices.empty?

    # Add a consistent & deterministic order
    offices.sort_by(&:created_at)

    short_list(offices) do |office|
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

  def user_email(user)
    if user.unconfirmed_email?
      message = t("user_email.unconfirmed_email")

      tag.span(class: "text-disabled", title: message) do
        concat svg_icon("arrow-path", class: "inline-block mr-2")
        concat user.unconfirmed_email
        concat tag.span(message, class: "tooltip")
      end
    elsif user.confirmed?
      mail_to user.email
    else
      message = t("user_email.unconfirmed_user")

      tag.span(class: "text-disabled", title: message) do
        concat svg_icon("envelope", class: "inline-block mr-2")
        concat user.email
        concat tag.span(message, class: "tooltip")
      end
    end
  end

  def check_badge(checked, title)
    if checked
      svg_icon("check-badge", title)
    else
      # Render a empty string to avoid empty placeholder
      " "
    end
  end
end
