# frozen_string_literal: true

module Reports
  class StateService
    def initialize(report)
      @report = report
    end

    def assign(params = nil)
      @report.assign_attributes(params) if params
      @report.validate
      @report.errors.add(:office_id, :blank) if @report.office_id.nil?

      if @report.errors.empty? && @report.assign!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def unassign
      if @report.unassign!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def deny(params = nil)
      @report.assign_attributes(params) if params

      if @report.valid? && @report.deny!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def undeny
      if @report.undeny!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def approve(params = nil)
      @report.assign_attributes(params) if params

      if @report.valid? && @report.approve!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def unapprove
      if @report.unapprove!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def reject(params = nil)
      @report.assign_attributes(params) if params

      if @report.valid? && @report.reject!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end

    def unreject
      if @report.unreject!
        Result::Success.new(@report)
      else
        Result::Failure.new(@report.errors)
      end
    end
  end
end
