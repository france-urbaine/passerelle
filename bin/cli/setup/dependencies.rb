# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class Dependencies < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        # Only do gem install if the much-faster gem list -i indicates we need
        # to — a pure local existence check, no RubyGems resolution/network,
        # unlike --conservative on its own. This only confirms some bundler is
        # present, not that it matches Gemfile.lock's BUNDLED WITH pin, but
        # `bundle install`/`bundle check` below auto-install that exact
        # version themselves if it's missing, so that gap is already covered.
        #
        # Gemfile.lock resolves rdoc to a newer version (currently 8.1.0, for
        # some other gem's "rdoc >= 4.0.0" dependency) than the one bundled as
        # a default gem with this Ruby (7.0.4). Both `gem list` and
        # `gem install` load every installed gem's rubygems_plugin.rb, so both
        # rdoc versions' plugin end up requiring their own lib/rdoc.rb, which
        # emits a page of "already initialized constant" warnings. RUBYOPT=-W0
        # silences Ruby's $VERBOSE warnings for this command only — RubyGems'
        # own `ERROR:` reporting (e.g. an actually missing gem) isn't affected.
        #
        say "Verify and install Bundler"
        run "gem list -i bundler --silent || gem install bundler --conservative", env: { "RUBYOPT" => "-W0" }

        # Only do bundle install if the much-faster bundle check
        # indicates we need to
        #
        say "Verify and install Ruby gems"
        run "bundle check || bundle install"

        # Only do yarn install if the much-faster yarn check --integrity
        # indicates we need to: it compares node_modules' own fingerprint
        # (node_modules/.yarn-integrity) with yarn.lock.
        #
        say "Verify and install JS packages"
        run "yarn check --integrity || yarn install"
      end

      def help
        say <<~MESSAGE
          Usage:

              #{bin_prefix('setup')} dependencies

          Install runtime dependencies:

              * Check for Bundler version
              * Install gems from Gemfile.lock
              * Install JS packages from package.json
          \x5
        MESSAGE
      end
    end
  end
end
