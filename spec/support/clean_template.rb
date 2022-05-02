# frozen_string_literal: true

module CleanTemplate
  def clean_template(template)
    template.gsub(/\n\s*(?=(<|>))/, "").squish.gsub(/\\n/, "\n")
  end
end
