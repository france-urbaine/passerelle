# frozen_string_literal: true

module ApplicationHelper
  include ComponentsHelper
  include TurboHelper
  include FormatHelper
  include FormHelper
  include RequestHelper

  def noscript(id: SecureRandom.alphanumeric, &block)
    concat(tag.noscript(id: "#{id}-noscript", &block))

    tag.script(id: "#{id}-script") do
      raw(<<~JS)
        document.getElementById("#{id}-noscript").remove();
        document.getElementById("#{id}-script").remove();
      JS
    end
  end
end