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
    viewer =
      case current_user.organization_type
      when "Collectivity", "Publisher" then :collectivity
      when "DGFIP"                     then :ddfip_admin
      when "DDFIP"
        if current_user.organization_admin? || current_user.user_form_types.any?
          :ddfip_admin
        else
          :ddfip_user
        end
      end

    Reports::SearchService.new(as: viewer).analyze_param(query)
  end
end
