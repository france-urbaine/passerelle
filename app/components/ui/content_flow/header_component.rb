# frozen_string_literal: true

module UI
  module ContentFlow
    class HeaderComponent < AbstractBlockComponent
      renders_one :title, "::UI::ContentFlow::TitleComponent"
      renders_many :actions, "GenericAction"
    end
  end
end
