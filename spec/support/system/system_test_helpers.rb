# frozen_string_literal: true

require "htmlbeautifier"

module SystemTestHelpers
  # Make failure screenshots compatible with multi-session setup.
  # That's where we use Capybara.last_used_session introduced before.
  #
  def take_screenshot
    return super unless Capybara.last_used_session

    Capybara.using_session(Capybara.last_used_session) { super }
  end

  # Allow to inspect the current HTML page or any capybara node.
  #
  def inspect_html(node = page)
    html =
      case node
      when Capybara::Session      then node.html
      when Capybara::Node::Simple then node.native.inner_html
      when Capybara::Node::Base   then node.native["innerHTML"]
      end

    puts HtmlBeautifier.beautify(html)
  end
end
