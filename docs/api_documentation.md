# API documentation

## Static pages & guides

Files added to `app/views/documentation/api/guides/` are automatically routed, but you have to add a link to the navbar to make them discoverable : `app/views/shared/_navbar_documentation.html.erb`

## Generating exemples
Exemples are generated using rspec :
```
APIPIE_RECORD=examples rspec --order defined spec/requests/api/
```

Only specs with the `:show_in_doc` keyword will be run to generate the documentation :

```ruby
it "lists all collectivities", :show_in_doc do
  expect(JSON.parse(response.body)["collectivites"].length).to eq(3)
end
```
Generated exemples are written in `doc/apipie_examples.json`

## Resources

The documentation for resources is generated using [apipie](https://github.com/Apipie/apipie-rails) with a few custom implementations.

### Icons
Icons for resources are set in the `resource_description` block in the matching controller :
```ruby
resource_description do
  ...
  meta icon: "building-library"
end
```

### Enums
To document an enum, add a meta attribute to your resource description :
```ruby
resource_description do
  ...
  meta enums: %w[territory_type]
end
```
The enum's values will then be infered from `config/locales/enum.fr.yml` and displayed in the documentation

You also have to link your resource attribute to the enum using another meta attribute :
```ruby
param :territory_type, String, "Type de territoire", meta: { enum: "territory_type" }
```


#### Customized enums partial
For more complicated enums, you might want to write a custom enum view.
If an `enums` partial is present in `app/views/documentation/api/references/$resource_id/` it will be used instead of the generated html from above.


### Additional informations
You can add additional documentation for any endpoint by creating a new partial: `app/views/documentation/api/references/$resource_id/$method`.
For exemple, to add information to the reports#create endpoint: `app/views/documentation/api/references/reports/_create.html.slim`

The partial will be rendered below the "informations" card.
