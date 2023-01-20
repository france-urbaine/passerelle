# README

This README would normally document whatever steps are necessary to get the application up and running.

## Requirements

* Ruby 3.1.2
* Bundler >= 2.x
* PostgreSQL
* Redis
* Yarn

## Configuration

This project uses environnement variables.  
In production, environnement variables must be defined through the cloud provider API.

In development & test, environnement variables may be optionnaly defined through `.env` file:

```
# .env
CUSTOM_KEY=fiscalite
```

You can define per-environment variables files: `.env.{development}`.  
Per-environment variables will overwrite those defined in `.env`.

```
# .env.development
CUSTOM_KEY=fiscahub_dev
```
```
# .env.test
CUSTOM_KEY=fiscahub_test
```

To load a given Rails environnement, use `RAILS_ENV` variable:

```shell
$ RAILS_ENV=production rails c
Loading production environment variables
 - load /Users/ink/dev/fiscahub/.env.production
 - load /Users/ink/dev/fiscahub/.env
Loading production environment (Rails 7.0.1)
>
```

To load an environment file, independent of Rails environnement, use `DOTENV` variable:

```shell
$ DOTENV=production rails c
Loading production environment variables
 - load /Users/ink/dev/fiscahub/.env.production
 - load /Users/ink/dev/fiscahub/.env
Loading development environment (Rails 7.0.1)
>
```

### Database configuration

If the default database configuration doesn't suit you, use the `.env` file:

```
# .env
POSTGRESQL_DATABASE=fiscahub
POSTGRESQL_HOST=0.0.0.0
POSTGRESQL_PORT=1234
POSTGRESQL_USER=marc
```

### Credentials

Credentials shared by all environnements are stored using Rails credentials feature.  
You need the master key to get access.  
You may put the key in `config/master.key` or in `.env`

```
# .env
RAILS_MASTER_KEY="<the_right_master_key>"
```

## Development

### Setup project

The `bin/setup` script will download Ruby & JS dependencies, prepare the development and test databases.

```shell
$ bin/setup
```

Then, start the development server (including JS & CSS builds) with:

```shell
$ bin/dev
```

### Code linting & tests

The test suite is running with Rspec.

```shell
$ bundle exec rspec
```

You can run the test suite in parallel with multiple CPU cores:

```shell
$ bundle exec rails parallel:spec
```

This project uses Rubocop to lint and format Ruby code:

```shell
$ bundle exec rubocop
```

The factories used in tests may also be linted:

```shell
$ bundle exec rails factory_bot:lint RAILS_ENV='test'
```

Alternatively, you can use guard to perform all these tasks on code changes:

```shell
$ guard
```

### Previews

User interface and components are documented and can be previewed at [http://localhost:3000/lookbook](http://localhost:3000/lookbook)

Mails can be previewed at [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)

### Catch mails

Sent mails can be catched with `mailcatcher`:

```shell
$ bin/mailcather
```

The command above will install the mailcatcher gem.  
If you experiment installation issue on MacOS,
take a look at the following links:
* https://github.com/sj26/mailcatcher#rvm
* https://github.com/sj26/mailcatcher#ruby
* https://github.com/eventmachine/eventmachine/issues/936

Mailcatcher listens to `smtp://127.0.0.1:1025` by default.  
If you need to listen to another port, redefine `SMTP_PORT` in `.env`:

```
# .env
SMTP_PORT=1027
```
