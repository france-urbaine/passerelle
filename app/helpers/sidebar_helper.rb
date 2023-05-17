# frozen_string_literal: true

module SidebarHelper
  def sidebar_link_to(*args, current: :__undef__, **options, &)
    path    = args.last
    current = current_path.start_with?(path) if current == :__undef__

    options[:class] = "sidebar__link"
    options[:class] += " sidebar__link--current" if current

    link_to(*args, **options, &)
  end
end
