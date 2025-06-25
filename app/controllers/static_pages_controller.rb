# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  layout "public"

  def cgu; end
  def privacy; end
end
