# frozen_string_literal: true

json.id @report.id
json.documents @report.documents.map do |document|
  json.partial! "show", document: document
end
