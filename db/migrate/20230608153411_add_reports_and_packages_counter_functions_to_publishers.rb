# frozen_string_literal: true

class AddReportsAndPackagesCounterFunctionsToPublishers < ActiveRecord::Migration[7.0]
  def change
    create_function :get_reports_count_in_publishers
    create_function :get_reports_completed_count_in_publishers
    create_function :get_reports_approved_count_in_publishers
    create_function :get_reports_rejected_count_in_publishers
    create_function :get_reports_debated_count_in_publishers
    create_function :get_packages_count_in_publishers
    create_function :get_packages_approved_count_in_publishers
    create_function :get_packages_rejected_count_in_publishers
  end
end
