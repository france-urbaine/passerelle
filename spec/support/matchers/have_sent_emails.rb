# frozen_string_literal: true

module Matchers
  module HaveSentEmails
    extend RSpec::Matchers::DSL

    matcher :have_sent_emails do
      include DeliveriesHelpers
      supports_block_expectations

      match do |actual|
        @actual = actually_delivered(actual)

        if defined?(@expected_size)
          @actual.size == @expected_size
        else
          @actual.any?
        end
      end

      match_when_negated do |actual|
        raise "Cannot combine .by with negative matcher (`expect.no_to have_sent_emails.by(n)`)" if @expected_size

        @actual = actually_delivered(actual)
        @actual.empty?
      end

      chain :by do |value|
        @expected_size = value
      end
    end

    matcher :have_sent_email do
      include DeliveriesHelpers
      supports_block_expectations

      match do |actual|
        @actual = actually_delivered(actual)
        @actual.any? do |mail|
          property_match?(:@recipient, mail.to) &&
            property_match?(:@sender, mail.from) &&
            property_match?(:@email_subject, mail.subject) &&
            property_match?(:@email_body, mail_body(mail))
        end
      end

      failure_message do
        actual               = ActionMailer::Base.deliveries
        actual_description   = actual.map { |mail| "  #{mail.inspect}" }.join("\n")
        actual_description   = "[\n#{actual_description}\n]"
        expected_description = description.gsub(/^have sent email/, "have one mail sent")

        "expected #{actual_description} to #{expected_description}"
      end

      chain :to do |value = nil, &block|
        @recipient = value || block
      end

      chain :from do |value = nil, &block|
        @sender = value || block
      end

      chain :with_subject do |value = nil, &block|
        @email_subject = value || block
      end

      chain :with_body do |value = nil, &block|
        @email_body = value || block
      end

      private

      def mail_body(email)
        HTMLEntities.new.decode(email.html_part.decoded)
      end
    end

    module DeliveriesHelpers
      def actually_delivered(actual)
        if actual.is_a?(Proc)
          previously_delivered = ActionMailer::Base.deliveries.clone
          actual.call
          ActionMailer::Base.deliveries - previously_delivered
        else
          ActionMailer::Base.deliveries
        end
      end

      def property_match?(expected_var, actual)
        return true unless instance_variable_defined?(expected_var)

        expected = instance_variable_get(expected_var)
        expected = expected.call if expected.is_a?(Proc)

        if actual.is_a?(Array)
          if expected.is_a?(Regexp) || expected.respond_to?(:matches?)
            actual.any? { |value| property_match_expectation?(expected, value) }
          else
            actual.include?(expected)
          end
        else
          property_match_expectation?(expected, actual)
        end
      end

      def property_match_expectation?(expected, actual)
        if expected.is_a?(Regexp)
          expected.match?(actual)
        elsif expected.respond_to?(:matches?)
          expected.matches?(actual)
        else
          expected == actual
        end
      end
    end
  end
end
