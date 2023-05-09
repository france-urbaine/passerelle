# frozen_string_literal: true

class UndiscardAllJob < ApplicationJob
  queue_as :default

  MODELS = %w[
    Collectivity
    DDFIP
    Publisher
    Office
    User
  ].freeze

  def perform
    MODELS.index_with do |model_name|
      model_name.constantize.discarded.quickly_undiscard_all
    end
  end
end
