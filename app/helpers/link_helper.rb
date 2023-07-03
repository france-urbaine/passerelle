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

  def authorized_links_to_offices(offices, ddfip_id, truncate: false)
    offices = offices.select { |office| office.kept? && office.ddfip_id == ddfip_id }
    return if offices.empty?

    buffer = []
    buffer << authorized_link_to(offices[0]) { offices[0].name }

    if truncate
      two_words_connector = " & "

      case offices.size
      when 2     then buffer << "1 autre"
      when (3..) then buffer << "#{offices.size - 1} autres"
      end
    else
      words_connector = last_word_connector = two_words_connector = "<br>".html_safe

      offices[1..].each do |office|
        buffer << authorized_link_to(office) { office.name }
      end
    end

    to_sentence buffer, words_connector:, last_word_connector:, two_words_connector:
  end
end
