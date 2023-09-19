# frozen_string_literal: true

require "fuubar"
require "turbo_tests/reporter"

module TurboFuubar
  def add(name, outputs)
    outputs.each do |output|
      formatter_class =
        case name
        when "p", "progress"
          RSpec::Core::Formatters::ProgressFormatter
        when "d", "documentation"
          RSpec::Core::Formatters::DocumentationFormatter
        else
          Kernel.const_get(name)
        end

      @formatters << formatter_class.new(output)
    end

    if name == "Fuubar"
      output = `bundle exec rspec --dry-run | grep 'examples, 0 failures'`
      example_count = output.split(" ").first.to_i
      delegate_to_formatters(:start, RSpec::Core::Notifications::StartNotification.new(example_count))
    end
  end
end

TurboTests::Reporter.prepend TurboFuubar
