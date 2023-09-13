# frozen_string_literal: true

class IconHiddenTransform < InlineSvg::CustomTransformation
  def transform(doc)
    with_svg(doc) do |svg|
      svg["hidden"] = value
    end
  end
end
