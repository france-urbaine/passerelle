# README

This README would normally document whatever steps are necessary to get the application up and running.

## Requirements

* Ruby 3.1.0
* Bundler >= 2.x
* PostgreSQL

### Configuration

This project uses environnement variables.

In production, environnement variables are defined through the cloud provider API.

In development & test, environnement variables may be defined through `.env` file:

```
CUSTOM_KEY=fiscalite
```

You can define per-environment variables files: `.env.{development}`.

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
POSTGRESQL_DATABASE=fiscahub
POSTGRESQL_HOST=0.0.0.0
POSTGRESQL_PORT=1234
POSTGRESQL_USER=marc
```

## Credentials

Credentials shared by all environnements are stored using the Rails feature.
You need the master key (shared on Dashlane) to get access.
You can put the key in `config/mast.key` or using `.env` file

```
RAILS_MASTER_KEY="<the_right_master_key>"
```

## Setup project

The setup script should bundle dependencies, prepare the development and test databases.

```shell
$ bin/setup
```

## Code linting & formating

This project use Rubocop to lint and format Ruby code :

```shell
$ bundle exec rubocop
```

## Tests

The test suite is running with Rspec.

```shell
$ bundle exec rspec
```

The suite might be running in parallel on multiple CPU cores:

```shell
$ bundle exec rails parallel:prepare
$ bundle exec rails parallel:spec
```

## Preview & catch mails in development

You can preview mail views at http://localhost:3000/rails/mailers

Mails can be catched with `mailcatcher`.
The gem should not be part of of the bundle.
You should install it manually and follow instructions:

```shell
$ gem install mailcatcher
$ mailcatcher
$ open http://localhost:1080/
```

If you experiment installation issue on MacOS:
* https://github.com/sj26/mailcatcher#rvm
* https://github.com/sj26/mailcatcher#ruby
* https://github.com/eventmachine/eventmachine/issues/936
