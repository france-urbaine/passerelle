# frozen_string_literal: true

# Adapted from https://github.com/rspec/rspec-expectations/issues/934#issuecomment-301269476
#
module Matchers
  module Invoke
    def invoke(expected_method)
      Matchers::InvokeMatcher.new(expected_method)
    end
  end

  class InvokeMatcher
    include RSpec::Matchers::Composable

    def initialize(expected_method)
      @expected_method = expected_method
      @have_received_matcher = RSpec::Mocks::Matchers::HaveReceived.new(@expected_method)
    end

    def description
      raise "missing `on`" unless defined?(@expected_recipient)

      "invoke #{@expected_method} on #{expected_recipient.inspect}"
    end

    def matches?(event_proc)
      raise "missing `on`" unless defined?(@expected_recipient)

      unless @expected_recipient.is_a?(RSpec::Mocks::Double)
        allow(@expected_recipient).to receive(@expected_method).and_call_original
      end

      event_proc.call

      @have_received_matcher.matches?(@expected_recipient)
    end

    def on(expected_recipient)
      @expected_recipient = expected_recipient
      self
    end

    RSpec::Mocks::Matchers::HaveReceived::CONSTRAINTS.each do |expectation|
      define_method expectation do |*args|
        @have_received_matcher = @have_received_matcher.public_send(expectation, *args)
        self
      end
    end

    delegate :failure_message,              to: :@have_received_matcher
    delegate :failure_message_when_negated, to: :@have_received_matcher

    def supports_block_expectations?
      true
    end

    def allow(_target)
      RSpec::Mocks::AllowanceTarget.new(@expected_recipient)
    end

    def receive(method_name)
      RSpec::Mocks::Matchers::Receive.new(method_name, nil)
    end
  end
end
