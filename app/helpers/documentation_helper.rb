# frozen_string_literal: true

module DocumentationHelper
  def apipie_documentation
    @apipie_documentation ||= begin
      Apipie.load_documentation if Apipie.configuration.reload_controllers? || !Rails.application.config.eager_load
      doc = Apipie.to_json(params[:version], nil, nil, :fr)
      doc[:docs] if doc
    end
  end
end
