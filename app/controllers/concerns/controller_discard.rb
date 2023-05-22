# frozen_string_literal: true

module ControllerDiscard
  class RecordDiscarded < StandardError
    attr_reader :record

    def initialize(record)
      @record = record
      super "Record is discarded: #{record}"
    end
  end

  def only_kept!(record)
    raise RecordDiscarded, record if record.discarded?
  end

  def gone_if_discarded(record)
    gone(record) if record.discarded?
  end
end
