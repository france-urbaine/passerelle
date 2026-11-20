# ViewComponents

All components inherit from `ApplicationViewComponent` (`application_view_component.rb`),
which provides `ComponentHelpers`, `HTMLAttributes`, ActionPolicy (`allowed_to?`),
`current_user` and `current_organization`.

## Namespaces

- `UI::` (`ui/`): generic building blocks (button, badge, card, modal, table, form…).
- `Layout::` (`layout/`): page structure (datatable, navbar, content layout, pagination…).
- `Views::<Resource>::` (`views/`): page-level components rendered by controllers,
  e.g. `Views::Reports::Show::Component`. Reuse `UI`/`Layout` components inside them.

## File structure

One directory per component:

```
ui/badge/
  component.rb             # UI::Badge::Component
  component.html.slim      # template (or a `call` method in component.rb)
  index.css                # component styles, imported by the CSS build
  preview.rb               # UI::Badge::Preview < ApplicationViewComponentPreview (Lookbook)
  previews/*.html.slim     # preview templates
```

Small view components may be a single `views/<resource>/<name>_component.rb` +
`.html.slim`, with translations in a sibling `<name>_component.fr.yml`.

## Conventions

- Accept extra HTML attributes with `**` and `@html_attributes = parse_html_attributes(**)`,
  then merge defaults with `reverse_merge_attributes`.
- Validate enum-like arguments in `initialize` and raise `ArgumentError`.
- Call `super()` at the end of `initialize`.
- Templates are Slim; styling is Tailwind plus component CSS classes (`badge--warning`).
- Add or update the Lookbook preview with the component (browse at `/lookbook`)
  and a spec in `spec/components/` mirroring the path.
