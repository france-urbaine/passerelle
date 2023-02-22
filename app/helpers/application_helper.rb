# frozen_string_literal: true

module ApplicationHelper
  include ComponentsHelper
  include FormHelper
  include FormatHelper
  include RequestHelper
  include SVGHelper
  include TurboHelper

  def noscript(id: SecureRandom.alphanumeric, &block)
    id = h(id)
    concat tag.noscript(id: "#{id}-noscript", &block)

    tag.script(id: "#{id}-script") do
      # rubocop:disable Rails/OutputSafety
      # The template is safe: the input is escaped above.
      <<~JS.html_safe
        document.getElementById("#{id}-noscript").remove();
        document.getElementById("#{id}-script").remove();
      JS
      # rubocop:enable Rails/OutputSafety
    end
  end
end
