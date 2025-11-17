# frozen_string_literal: true

module ControllerAdvancedSearch
  def advanced_search_records(relation, query)
    return relation if query.blank?

    case relation.klass.name
    when "Report" then query = analyze_query_for_reports(query)
    end

    relation.search(query)
  end

  private

  def analyze_query_for_reports(query)
    viewer = Users::RoleService.new(current_user).viewer_type
    Reports::SearchService.new(as: viewer).analyze_param(query)
  end
end
