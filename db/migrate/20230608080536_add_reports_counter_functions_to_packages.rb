# frozen_string_literal: true

class AddReportsCounterFunctionsToPackages < ActiveRecord::Migration[7.0]
  def change
    create_function :get_reports_count_in_packages
    create_function :get_reports_completed_count_in_packages
    create_function :get_reports_approved_count_in_packages
    create_function :get_reports_rejected_count_in_packages
    create_function :get_reports_debated_count_in_packages
    create_function :reset_all_packages_counters
  end
end
