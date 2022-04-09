# Uniqueness validations and accents

Rails performs case insensitive validation using Postgres LOWER function
Depending on how database locale has been initialized, LOWER can or cannot
performs a proper lowercase on accents:

```SQL
=> SHOW LC_CTYPE;
 C

=> SELECT LOWER('VENDÉE');
 vendÉe
```

In local, it can lead to unmet validations or failed specs.

Fortunately, in production, the locale has been set to handle most accents used in France:

```SQL
=> SHOW LC_CTYPE;
 en_GB.utf8

=> SELECT LOWER('VENDÉE');
 vendée
```
