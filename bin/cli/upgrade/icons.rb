# frozen_string_literal: true

require_relative "../base"

module CLI
  module Upgrade
    class Icons < Base
      SETS = %w[
        heroicons
      ].freeze

      def call(*)
        sets, = parse_options!(*, arguments_expected: true)

        sets.each do |set|
          raise ArgumentError, "unexpected set: #{set.inspect}" unless SETS.include?(set)
        end

        sets = SETS if sets.empty?
        sets.each do |set|
          case set
          when "heroicons"
            say "Upgrading Heroicons"
            run "git submodule update --remote vendor/submodules/heroicons"
          end
        end
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('upgrade')} icons [SET, ...]

          Upgrade all icon sets, or the one provided.
          Available icon sets are:

              heroicons
          \x5
        HEREDOC
      end
    end
  end
end
