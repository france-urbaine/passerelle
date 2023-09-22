# frozen_string_literal: true

module ControllerDiscard
  class RecordDiscarded < StandardError
    attr_reader :records

    def initialize(records)
      @records = records
      super "Record is discarded: #{records.last.inspect}"
    end
  end

  # You can pass one or several records to `only_kept!`
  # The first discarded record and all the following (discarded or not)
  # will be pushed into @gone_records
  #
  def only_kept!(*records, **)
    records.compact!
    return unless (first_index = records.index(&:discarded?))

    gone_records = records[first_index..]
    raise RecordDiscarded, gone_records
  end

  def undiscard_action(path, params = nil)
    if params.nil? && action_name == "destroy_all"
      params = self.params
        .slice(:search, :order, :page, :ids)
        .permit(:search, :order, :page, :ids, ids: [])
        .to_h
        .symbolize_keys
    end

    path = polymorphic_path(path.compact) if path.is_a?(Array)

    {
      label:  "Annuler",
      method: "patch",
      url:    path,
      params: params&.compact || {}
    }
  end

  def respond_to_missing?(*)
    undiscard_action_method_to_path(*)
  end

  def method_missing(*)
    path = undiscard_action_method_to_path(*)
    path ? undiscard_action(path) : super
  end

  private

  def undiscard_action_method_to_path(method, *)
    method.match(/(undiscard_[_a-z]*)_action/).try do |m|
      path_method = "#{m[1]}_path"
      send(path_method, *) if respond_to?(path_method)
    end
  end
end
