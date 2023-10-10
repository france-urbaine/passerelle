# frozen_string_literal: true

json.extract! document, :id, :filename
json.url url_for(document)
