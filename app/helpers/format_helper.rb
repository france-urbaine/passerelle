# frozen_string_literal: true

module FormatHelper
  def display_count(count_or_relation, *args, **options)
    case count_or_relation
    when Integer                then count = count_or_relation
    when ActiveRecord::Relation then count = count_or_relation.size
    else raise TypeError, "invalid count"
    end

    inflections = InflectionsOptions.new(*args, **options)

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
end
