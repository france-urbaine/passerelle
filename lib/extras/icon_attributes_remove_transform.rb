# frozen_string_literal: true

class IconAttributesRemoverTransform < InlineSvg::CustomTransformation
  def transform(doc)
    with_svg(doc) do |svg|
      Array.wrap(value).each do |attribute|
        svg.delete attribute.to_s.gsub("_", "-")
      end
    end
  end
end

