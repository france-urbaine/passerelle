# frozen_string_literal: true

module NavbarHelper
  def navbar_link_to(*args, current: :__undef__, **options, &)
    path    = args.last
    current = request.fullpath.start_with?(path) if current == :__undef__

    options[:class] = "navbar__link"
    options[:class] += " navbar__link--current" if current

    link_to(*args, **options, &)
  end
end
