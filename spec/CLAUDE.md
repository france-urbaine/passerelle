# Specs

RSpec with FactoryBot, shoulda-matchers, moarspec, Capybara + Cuprite (system),
WebMock, Timecop and test-prof. Every spec file starts with
`# frozen_string_literal: true` and `require "rails_helper"` (system specs:
`require "system_helper"`).

## Running tests

Tests run inside Docker, through `bin/dx`:

```shell
bin/dx ci test [unit|system|requests|components|failed]   # whole scopes
bin/dx rspec spec/path/to/file_spec.rb                    # single file
bin/dx rspec spec/path/to/file_spec.rb:42                 # single example
```

Test databases and assets: `bin/dx setup test`. In CI, specs run in parallel
with `parallel_tests` (`CI_PARALLEL=true`).

## Layout

Mirrors `app/`: `models`, `services`, `policies`, `requests`, `routing`,
`components`, `jobs`, `mailers/previews`, `lib`, `system`. Factories are in
`spec/factories/<plural>.rb`; run `bin/dx ci factories` after changing one.
Support code is in `spec/support/` (helpers per spec type, shared contexts,
custom matchers).

## Writing specs

These rules codify patterns the suite already follows. Grep for an existing
example before deviating.

### Determinism: no flaky specs

- `config.order = :random`: examples must not depend on each other or on load
  order. No shared mutable state at module/class level; each example gets its own
  data via `let`/factories.
- No wall-clock dependence: use `Timecop.freeze` / `Timecop.travel`, never
  `sleep`, and never assert against a freshly computed `Time.now`/`Date.current`.
  `Timecop.return` runs automatically after every example (`spec/rails_helper.rb`,
  opt out with `:prevent_timecop_to_return`), so don't hand-roll teardown. Prefer
  the block form of `Timecop.freeze`, or read `Time.current` after freezing rather
  than relying on its return value.
- No real network calls: stub them with WebMock.
- If a spec is actually flaky, find the root cause (unstubbed time/network,
  a race, state leaking across parallel workers). Don't paper over it with
  `sleep`, retries, longer timeouts or `:skip`.

Known flaky patterns to check a new spec against:

- **Implicit ordering.** A query without `ORDER BY` has no guaranteed order in
  Postgres. Use `contain_exactly`/`match_array` when order isn't part of the
  contract; when it is (rendered output, JSON), sort in the app code that
  consumes the collection.
- **Random factory defaults colliding with the example.** Pin every attribute
  the outcome depends on (a value expected to change from/to, submitted or
  compared), otherwise a random default occasionally equals it.
- **Uniqueness collisions.** Don't hardcode a unique-constrained value (SIREN,
  code INSEE…) on several records; let the factory generate it and read it back
  from the record. Factories with unique columns use Faker's `.unique`
  (e.g. `spec/factories/collectivities.rb`); it is cleared after every example.
- **Time computed while building the matcher.** Matcher arguments are evaluated
  before the `expect { }` block runs (e.g. a rotating OTP code): wrap the whole
  expectation in a `Timecop.freeze` block.
- **System specs racing the app.** Enter a page the way users do (click from its
  real parent page) rather than `visit`ing a deep URL. Synchronize on something
  Capybara waits for (e.g. the flash notification), not `have_current_path` when
  the URL never changes.
- **Accents and case-insensitive uniqueness** behave differently depending on
  the database locale: see `docs/uniqueness_validations_and_accents.md`.

### Test behavior, not implementation

- Assert on return values, persisted state or rendered output, not on which
  private methods were called. Avoid `expect(object).to receive(:internal_method)`
  on your own collaborators.
- Mock only real boundaries: HTTP (WebMock), external downloads, mailers/jobs
  delivery. Build real collaborators with factories instead of stubbing internal
  services, unless setup is prohibitively expensive.
- Services return a `Result`: assert on `result` (`be_a(Result::Success)` /
  `be_a(Result::Failure)`, `errors`) and on the persisted record.

### Factories & data setup

- Reuse factories in `spec/factories/` instead of `Model.new`/`create!` with
  hand-rolled attributes. Prefer a trait over a new factory when only a few
  attributes differ.
- Keep factory definitions minimal (just what's required for validity). One-off
  attributes belong in the spec: `create(:report, situation_invariant: "...")`.
- Use `build`/`build_stubbed` instead of `create` when the example doesn't
  exercise DB behavior (associations, validations, uniqueness, callbacks).
- test-prof's `let_it_be`/`before_all` are loaded: use them for read-only
  records shared by every example of a group (a parent `ddfip`, `region`…), not
  for records an example mutates.
- Signed-in users: use the per-type helpers (`sign_in(user)`,
  `sign_in_as(:publisher, organization: publisher)`, which take user factory traits,
  in `spec/support/{request,component}/authentication_helpers.rb`); don't set
  Warden/session state by hand. API request specs use `setup_access_token` +
  `authorization_header`.
- Don't add a `let` that only aliases an attribute of another record
  (`let(:siren) { collectivity.siren }`); write `collectivity.siren` where it's used.

### Testing scopes: assert the SQL for non-trivial ones

For a scope whose value is in its query shape (join, subquery, raw SQL), assert
the generated SQL with `perform_sql_query` (`spec/support/matchers/perform_sql_queries.rb`,
SQL is squished automatically) instead of building fixtures and checking which
records come back:

```ruby
it "searches for EPCIs having communes from the given relation" do
  expect {
    described_class.having_communes(Commune.where(code_departement: "64")).load
  }.to perform_sql_query(<<~SQL)
    SELECT "epcis".*
    FROM   "epcis"
    WHERE  "epcis"."siren" IN (
      SELECT "communes"."siren_epci"
      FROM   "communes"
      WHERE  "communes"."code_departement" = '64'
    )
  SQL
end
```

See `spec/models/epci_spec.rb`. A plain `where(column: value)` scope is still
fine tested with records.

### Minimize `let` and `context` nesting

- Use `let`/`let!` when several examples share the same records, or when a
  shared example expects a specifically named `let`. When only one example needs
  a record, define it in that example.
- Avoid towers of single-use `let`s that only compose each other once.
- A `context` nested just to hold one `it`, with nothing to contrast it with,
  usually reads better flattened into a descriptive `it`. Keep nesting where it
  mirrors a real combinatorial structure, e.g. the authorization matrices of
  request and policy specs. A `context` normally has an opposed sibling
  (`"when transmitted"` / `"when packing"`).

### Style & structure

- Always describe `it` (`it "does the thing" do`), never a bare `it do`. The
  only exception is a one-line matcher: `it { is_expected.to belong_to(:ddfip) }`.
- Write `expect { }` blocks on multiple lines, even for a single call, so the
  call under test stands apart from the matchers.
- Don't chain a count and arguments in one `send_message` / `have_enqueued_job`
  expectation (`.once.with(args)`): it only counts matching calls, so an extra
  call with other arguments goes unnoticed. Assert the total count once, then
  each `.with(args)` separately:
  ```ruby
  expect {
    service.update
  }
    .to  send_message(ImportCommunesJob, :perform_now).once
    .and send_message(ImportCommunesJob, :perform_now).with("https://www.insee.fr/path/communes.zip")
  ```
- Reuse shared examples and contexts (`spec/support/request/shared_*`,
  `spec/support/policy/shared_user_contexts.rb`, `spec/models/shared_examples.rb`),
  e.g. `it_behaves_like "it allows access to DDFIP admin"` /
  `"it denies access to collectivity user"`. Copy the authorization matrix from a
  sibling spec instead of inventing contexts. Only extract a new shared example
  once there's a second real call site.
- Lay out examples as **arrange / act / assert**, separated by blank lines.
  Keep local names short, align consecutive assignments, and assert several
  attributes with one `have_attributes(...)`, taking expected values from the
  fixture records rather than duplicating them.
- Policy specs use the `expect(:create?)` style (allowed by rubocop here).
- `described_class` is not required (`RSpec/DescribedClass` off).
  `ExampleLength` and `NestedGroups` are disabled and `MultipleExpectations` is
  off for components/requests/system specs; that's not license for sprawling specs.
- Custom matchers in `spec/support/matchers/`: `perform_sql_queries`,
  `have_flash`, `have_sent_emails`, `have_html_attribute`, `have_body`,
  `have_content_type`, `invoke`, `render_preview_without_exception`.
- Component specs use `render_inline` and assert on `page`. Every Lookbook
  preview is rendered by the preview specs, so a new preview must render.
- API examples for the docs come from request specs tagged `:show_in_doc`
  (see `docs/api_documentation.md`); don't edit `doc/apipie_examples.json` by hand.

### Before calling a spec done

Run the spec file and rubocop on it, don't assume from reading the code:

```shell
bin/dx rspec spec/path/to/file_spec.rb
bin/dx exec bundle exec rubocop spec/path/to/file_spec.rb
```
