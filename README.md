# Passerelle (formerly known as Fiscahub)

## Requirements

* Ruby 3.2.2
* PostgreSQL
* Redis
* Yarn

System tests require Chrome or Chromium to be installed
(see [Ferrum](https://github.com/rubycdp/ferrum)).

## Setup

Download the project, install requirements and run:

```shell
$ bin/setup
```

## Running the app

To start the application, run:

```shell
$ bin/dev
```

## Tests and continuous integration 

To run the full CI suite, run:

```shell
$ bin/ci
```

To get more options about how to run tests and CI, run:

```shell
$ bin/ci help
```


## Additional configuration

Depending on runtime, we might use environnement variables to define custom configuration.

In production, environnement variables must be defined through the cloud provider API.  

In development & test, environnement variables may be defined in `.env` files.  
Learn more about `.env` files at https://github.com/bkeepers/dotenv


## Secrets

Secrets and credentials shared by all environnements are stored using Rails credentials feature.  

Learn more about credentials with:

```
bin/rails credentials:help
```

## Development

### Subdomains

Some part of the application, use subdomains, such as `api.`.  
The default Rails host is `localhost` or `127.0.0.1` but it doesn't allow to use subdomains.  
We need a domain with a longer TLD:

* The free DNS resolver `lvh.me` allow you to use subdomains out of the box in development & test.
  Once the server is running, go to http://lvh.me:3000

* To avoid depending on a third-party resolver, you can add "lvh.me" to your `/etc/hosts`:

  ```
  127.0.0.1 lvh.me
  127.0.0.1 api.lvh.me
  ```

* You can also setup a custom domain by adding it to your domain to `.env.development`:
  
  ```
  DOMAIN_APP = localhost.local
  ```
  
  Then configure your `/etc/hosts` file to add the corresponding domains:

  ```
  127.0.0.1 localhost.local
  127.0.0.1 api.localhost.local
  ```

NOTE: `localhost.local` may not working when running system specs.
You'd better use `lvh.me` or any other custom domain.

### Previews

Components and UI can be previewed at [http://localhost:3000/lookbook](http://localhost:3000/lookbook)

Mails can be previewed at [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)

### Mail catching

In development, mails can be catched with `mailcatcher`:

```shell
$ bin/mailcatcher
```
