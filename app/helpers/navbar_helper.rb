# frozen_string_literal: true

module NavbarHelper
  def navbar_link_to(*args, current: :__undef__, disabled: false, **, &)
    href = args.last if block_given? || args.size > 1

    if href.nil?
      args << "/"
      disabled = true
    end

    current = false if disabled

    current = href == "/" ? href == request.path : request.fullpath.start_with?(href) if current == :__undef__

    css_classes  = "navbar__link"
    css_classes += " navbar__link--current" if current

    button_component(*args, disabled:, class: css_classes, **, &)
  end

  def navbar_icon_link_to(*args, disabled: false, **, &)
    href = args.last if block_given? || args.size > 1

    if href.nil?
      args << "/"
      disabled = true
    end

    tag.div(class: "navbar__icon-link") do
      button_component(*args, disabled:, icon_only: true, **, &)
    end
  end
end
