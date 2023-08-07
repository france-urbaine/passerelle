# frozen_string_literal: true

module FormatHelper
  def display_count(count_or_relation, ...)
    case count_or_relation
    when Integer                then count = count_or_relation
    when ActiveRecord::Relation then count = count_or_relation.size
    else raise TypeError, "invalid count"
    end

    inflections = InflectionsOptions.new(...)

    capture do
      case count
      when 0 then "0 #{inflections.singular}"
      when 1
        concat tag.b(1)
        concat " "
        concat inflections.singular
      else
        concat tag.b(number_with_delimiter(count))
        concat " "
        concat inflections.plural
      end
    end
  end

  def page_count(pagy)
    "Page #{number_with_delimiter(pagy.page)} sur #{number_with_delimiter(pagy.pages)}"
  end

  def display_siren(siren)
    capture do
      parts = siren.scan(/\d{3}/)
      parts[0..-2].each do |part|
        concat tag.span(part, class: "mr-1")
      end

      concat tag.span(parts[-1])
    end
  end

  def display_surface(value)
    "#{number_with_delimiter(value)} m²" if value
  end

  def display_parcelle(parcelle)
    return unless parcelle&.match(ApplicationRecord::PARCELLE_REGEXP)

    [
      $LAST_MATCH_INFO[:prefix]&.rjust(3, "0"),
      $LAST_MATCH_INFO[:section],
      $LAST_MATCH_INFO[:plan]&.rjust(4, "0")
    ].compact.join(" ")
  end

  def display_date(date)
    case date
    when Date
      I18n.l(date, format: "%-d %B %Y")

    when ApplicationRecord::DATE_REGEXP
      args   = $LAST_MATCH_INFO.values_at(:year, :month, :day).compact.map(&:to_i)
      date   = Date.new(*args)
      format = ["%-d", "%B", "%Y"][(0 - args.size)..].join(" ")

      value = I18n.l(date, format:)
      value = value.titleize if value.match?(/\A[A-Z]/)
      value

    when String
      date = Date.parse(date)
      I18n.l(date, format: "%-d %B %Y")
    end
  end

  def list(collection, &)
    return if collection.empty?

    collection = collection.map.with_index(&) if block_given?
    collection.map! do |item|
      tag.li { item }
    end

    tag.ul do
      safe_join collection
    end
  end

  def short_list(collection, humanize: false, &)
    list = []

    if collection.size <= 2
      list = collection
      list = list.map.with_index(&) if block_given?
      list[1] = list[1][0].downcase.concat(list[1][1..]) if humanize && list[1].present?
    else
      list = collection[0, 1]
      list = list.map.with_index(&) if block_given?
      list << "#{collection.size - 1} autres"
    end

    to_sentence(list, two_words_connector: " & ")
  end
end
