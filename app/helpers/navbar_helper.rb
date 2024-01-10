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

  # FIXME: https://bugs.ruby-lang.org/issues/20090
  # Anonymous parameters & blocks cannot be forwarded within block in Ruby 3.3.0
  # May be fixed in Ruby 3.3.1
  #
  def navbar_icon_link_to(*args, disabled: false, **kwargs, &block)
    href = args.last if block || args.size > 1

    if href.nil?
      args << "/"
      disabled = true
    end

    tag.div(class: "navbar__icon-link") do
      button_component(*args, disabled:, icon_only: true, **kwargs, &block)
    end
  end
end
