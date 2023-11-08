# frozen_string_literal: true

module UI
  module ContentFlow
    class HeaderComponent < AbstractBlockComponent
      renders_many :actions
    end
  end
end
