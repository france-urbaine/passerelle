# frozen_string_literal: true

class DialogComponent < ViewComponent::Base
  attr_reader :back_url

  def initialize(back_url: nil)
    @back_url = back_url
  end
end
