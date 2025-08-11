# Passerelle

## Requirements

* Ruby 3.4.4
* PostgreSQL 14+
* Redis
* Yarn

## Setup

Download the project, install requirements and run:

```shell
$ bin/setup
```

To get more options about setup steps, you can try:

```shell
$ bin/setup help
```

## Running the app

To start the application, just run:

```shell
$ bin/dev
```

To get more options about running processes, you can try:

```shell
$ bin/dev help
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

## Subdomains

Some part of the application, use subdomains, such as `api.`.

In development, uses the domain [passerelle-fiscale.localhost](http://passerelle-fiscale.localhost:3000) to navigate between subdomains out of the box.

## Previews

UI components can be previewed at [http://localhost:3000/lookbook](http://localhost:3000/lookbook)

Mails can be previewed at [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)
