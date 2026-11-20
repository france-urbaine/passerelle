# Passerelle

Rails 8.1 app (Ruby 4.0.9) through which collectivities and publishers transmit
tax reports ("signalements") to the DDFIP/DGFIP, who then accept, assign,
resolve and confirm them. The UI, URLs, locales and domain vocabulary are
French (`config.i18n.default_locale = :fr`, the only available locale).

## Running commands

The dev environment runs in Docker (app, PostgreSQL, Redis) managed by `bin/dx`.
Run project commands through it rather than on the host:

```shell
bin/dx ci                          # Full CI: zeitwerk, factories, tests, rubocop, brakeman, audit
bin/dx ci test [unit|system|requests|components|failed|path/to/file_spec.rb]
bin/dx rspec spec/models/report_spec.rb:42
bin/dx ci rubocop                  # or: bin/dx exec bundle exec rubocop -a <files>
bin/dx ci zeitwerk                 # Check class loading after adding/renaming files
bin/dx ci factories                # Lint FactoryBot factories
bin/dx rails <args>                # e.g. bin/dx rails db:migrate
bin/dx dev                         # Start web, js, css, sidekiq, mailcatcher
```

Every `bin/*` command supports `--help`. If `bin/dx` fails because containers
aren't running, `bin/dx start` first.

## Architecture

- **Controllers** stay thin: `authorize!` / `authorized(scope)` via ActionPolicy,
  delegate writes to a service, then `respond_with result, flash: true, location: ...`
  (custom responder in `app/controllers/concerns/application_responder.rb`).
  Shared behaviour lives in `app/controllers/concerns/controller_*.rb`.
- **Services** (`app/services/<plural_model>/*_service.rb`) subclass `FormService`
  (`lib/extras/form_service.rb`), wrap a record, and `save` returns a
  `Result::Success` / `Result::Failure` (`lib/extras/result.rb`). Report state
  transitions are in `app/services/reports/states/`.
- **Policies** (`app/policies/`) handle both rules and params filtering
  (`authorized(params.fetch(:report, {}))`); there is no strong-params `permit` in controllers.
  Authorization depends on organization type: Publisher, Collectivity, DDFIP, DGFIP
  — and on the user role (user / admin / super admin, plus form admin / office user for DDFIP).
- **Views** are mostly ViewComponents (`app/components/`, see its CLAUDE.md);
  controllers `render Views::<Resource>::<Action>::Component.new(...)`. Plain
  templates are Slim.
- **Models**: UUID primary keys, soft-delete with `discard` (`Discardable` concern,
  `only_kept!` in controllers, `remove`/`undiscard` routes), `audited`. Report
  lifecycle is `app/models/concerns/states/report_states.rb`.
- **API** (`api.` subdomain): Doorkeeper OAuth + apipie docs. See
  `docs/api_documentation.md` for documenting endpoints and regenerating examples.
- **Jobs**: Sidekiq.
- **Front-end**: Turbo + Stimulus (`app/javascript/controllers`), esbuild,
  Tailwind 4 via PostCSS. Icons come from the heroicons git submodule
  (`vendor/submodules/heroicons`).

## Database

- Schema is `db/structure.sql` (`schema_format = :sql`), never `schema.rb`.
- Counter caches and stats rely on SQL functions/triggers managed with the `fx`
  gem (`db/functions/*_vNN.sql`, `db/triggers/*_vNN.sql`). To change one, add a
  new version file and a migration using fx helpers (`create_function`,
  `update_function`, `drop_function ..., revert_to_version:`, same for triggers);
  don't edit an existing version.
- After migrations, model schema comments are refreshed by `annotaterb`; keep
  them in sync.
- Case-insensitive uniqueness may behave differently locally vs production with
  accents: see `docs/uniqueness_validations_and_accents.md`.

## Conventions

- Rubocop is enforced in CI (`.rubocop.yml`): double quotes, `# frozen_string_literal: true`,
  `braces_for_chaining`, fixed-indentation argument alignment, aligned
  assignments/hashes in columns as seen throughout the code. Run it on the files you touch.
- Acronyms are inflected (`DDFIP`, `DGFIP`, `EPCI`, `API`, `UI`, `HTML`, `SVG`,
  `XLSX`): classes are `DDFIP`, `EPCIs`, `UI::Button::Component`, but files stay
  snake_case (`ddfip.rb`). `bin/ci zeitwerk` catches mismatches.
- Routes use French paths (`/signalements`, `/paquets`) and UUID id constraints;
  controller actions follow the order in `Rails/ActionOrder` (index, show, new,
  create, edit, update, remove, destroy, undiscard, remove_all, destroy_all, undiscard_all).
- User-facing strings go in `config/locales/*.fr.yml` (or a component's sibling `*.fr.yml`).
- Commit messages: short imperative English sentence, no prefix
  (e.g. "Add help to bin/ci factories", "Upgrade rails to 8.1.2").

## Git branch naming

Branches follow `[type]-[team/theme]-[subject]`: three parts separated by hyphens,
each part lowercase with only letters, digits and underscores inside — never a
hyphen inside a part. This applies to any branch created on the user's behalf,
including worktrees.

- **type**: one of `sprint`, `feature`, `refacto`, `bugfix`, `experiment`,
  `upgrade`.
- **team/theme**: `sprint-<team>` (e.g. `sprint-fiscal`); for other types, a
  general theme (e.g. `feature-reports`, `bugfix-api`, `upgrade-bin`).
- **subject**: the specific topic, `snake_case`.

Examples: `feature-reports-add_documents_upload`, `bugfix-api-fix_transmission_status`,
`upgrade-deps-rails_8_1`.

If a requested name doesn't fit, adapt it (`bugfix` for a fix, `refacto` for a
refactor, `feature` for new functionality, `upgrade` for a dependency bump,
`experiment` for exploratory work), and tell the user the adapted name before
creating the branch. If the team/theme isn't obvious, ask.

## Previews

- Components: http://localhost:3000/lookbook
- Mailers: http://localhost:3000/rails/mailers
- Subdomains in dev: http://passerelle-fiscale.localhost:3000

## AI tooling (rails-hyperdrive)

- `rails-hyperdrive` mounts an MCP server at `/_hyperdrive/mcp` in development
  only, declared in `.mcp.json`. It is available while `bin/dx dev` runs and
  offers live introspection (`run_ruby`, read-only `run_sql`, `list_routes`,
  `list_models`, `locate_source`, `tail_logs`…): prefer it over grepping
  `routes.rb` or replaying migrations when the server is up.
- The URL uses `${PASSERELLE_PORT:-3000}`, which must match the host port Rails
  is published on: `PORT` in `.docker/docker-compose.local.env` (untracked,
  generated by `bin/dx build`, 3000 when unset). Claude Code only expands it
  from the shell environment it was launched from: a project `.env` or an
  `env` entry in `.claude/settings*.json` doesn't work. To keep it in sync,
  derive it from that file in your shell profile (`~/.zshrc`), adjusting the
  path to your checkout:

  ```shell
  # Passerelle: MCP port follows PORT from .docker/docker-compose.local.env
  passerelle_port=$(sed -n 's/^PORT=//p' ~/dev/passerelle/.docker/docker-compose.local.env 2>/dev/null)
  [ -n "$passerelle_port" ] && export PASSERELLE_PORT=$passerelle_port
  unset passerelle_port
  ```

  After changing `PORT`, run `bin/dx restart`, then open a new shell and
  restart Claude Code. Don't export an empty `PASSERELLE_PORT`: it would expand
  to an empty port instead of the 3000 default. When `PORT` is changed in this
  session, or `claude mcp list` / `/mcp` shows rails-hyperdrive failing to
  connect, compare `echo $PASSERELLE_PORT` with `PORT` in that file and remind
  the user to update their shell.
- Companion content (the `layered-rails` skill, agents and `/layered-rails-*`
  commands from `layered-rails-skills`) lives in `.claude/` and is tracked in
  `.hyperdrive/lock.yml`. Don't edit those files casually: after adding or
  upgrading a companion gem, run `bin/dx rails hyperdrive:sync`. The
  `bundler-hyperdrive` Gemfile plugin is deliberately not registered, so it
  doesn't install in CI and production.

Deployment (tag + push to CleverCloud) is described in `DEPLOY.md`; never push to the `production` remote unasked.
