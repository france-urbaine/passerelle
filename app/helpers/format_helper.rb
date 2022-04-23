# frozen_string_literal: true

module FormatHelper
  def count(count_or_relation, word, plural: nil)
    case count_or_relation
    when Integer                then count = count_or_relation
    when ActiveRecord::Relation then count = count_or_relation.size
    else raise TypeError, "invalid count"
    end

    capture do
      case count
      when 0 then "0 #{word}"
      when 1
        concat tag.b(1)
        concat " "
        concat word
      else
        concat tag.b(number_with_delimiter(count))
        concat " "
        concat plural || word.pluralize
      end
    end
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

  def display_errors(record, attribute)
    capture do
      record.errors.messages_for(attribute).each do |error|
        concat tag.div(error, class: "form-block__errors")
      end
    end
  end
end