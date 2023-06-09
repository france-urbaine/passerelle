# frozen_string_literal: true

module Matchers
  module BeANullRelation
    extend RSpec::Matchers::DSL

    def be_a_null_relation
      be_a(ActiveRecord::NullRelation)
    end
  end
end
