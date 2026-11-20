# bin/ scripts

`bin/dx`, `bin/ci`, `bin/dev`, `bin/setup`, `bin/update` and `bin/upgrade` are
thin entry points that `require_relative "cli/<name>"` and call `CLI::<Name>.run`.
The logic lives in `bin/cli/`.

## Constraints

- **Plain Ruby, standard library only.** These scripts run on the host before
  any gem is installed (`bin/dx` needs only Ruby). No Rails, ActiveSupport,
  Zeitwerk or gems: load files explicitly with `require_relative`.
- Rubocop's Rails cops are disabled for `bin/**/*`; other cops still apply.

## Structure

- `bin/cli/base.rb`: `CLI::Base`, which includes `LinesCommander`
  (`lib/extras/lines_commander.rb`) for `say`, `ask`, `run`, `colorize`,
  `confirm_before_calling_destructive_method`, etc.
- `bin/cli/<command>.rb`: a `CLI::<Command>` module with `def self.run = Default.run`
  and a `Default < Base` class that dispatches subcommands with a `case`.
- `bin/cli/<command>/<sub>.rb`: one class per subcommand (`CLI::CI::Factories < Base`).
- `bin/cli/docker/defaults.rb`: shared Docker defaults for `bin/dx` subcommands.

## Adding or changing a subcommand

1. Create `bin/cli/<command>/<sub>.rb` with `call(*)` and a `help` method.
2. Parse args with `parse_options!(*, with: options_parser, arguments_expected: false)`;
   defining `help` automatically adds `-h/--help`.
3. Write help text with `#{bin_prefix('<command>')}` so it prints
   `bin/dx <command>` when run through Docker (see `KNOWN_SHORTCUTS` in `base.rb`).
4. Register it in the `case` of `bin/cli/<command>.rb` **and** in the
   "Available commands" list of its `help`.
5. Check it by hand: `ruby bin/<command> --help` and `ruby bin/<command> <sub> --help`.

Changes to `bin/*` and `*.md` don't trigger the GitHub CI workflow, so run
`bundle exec rubocop bin` yourself.
