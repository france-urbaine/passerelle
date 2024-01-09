# frozen_string_literal: true

# HTML output format (Possible formats :html, :xhtml, :xml)
# Slim::Engine.options[:format] = :xhtml

# Character to wrap attributes in html (can be ' or ")
# Slim::Engine.options[:attr_quote] = '"'

# Joining character used if multiple html attributes are supplied (e.g. class="class1 class2")
# Slim::Engine.options[:merge_attrs] = ' '

# Attributes which will be hyphenated if a Hash is given
# (e.g. data=a_foo:1,b:2 will render as data-a_foo="1" data-b="2")
# Slim::Engine.options[:hyphen_attrs] = %w[data]

Slim::Engine.options[:hyphen_attrs] = %w[aria data]

# Attributes that have underscores in their names will be hyphenated
# (e.g. data=a_foo:1,b_bar:2 will render as data-a-foo="1" data-b-bar="2")
# Slim::Engine.options[:hyphen_underscore_attrs] = false

Slim::Engine.options[:hyphen_underscore_attrs] = true

# Sort attributes by name
# Slim::Engine.options[:sort_attrs] = true

# Pretty HTML indenting, only block level tags are indented (This is slower!)
# Slim::Engine.options[:pretty] = false
