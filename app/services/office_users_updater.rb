# frozen_string_literal: true

class OfficeUsersUpdater
  def initialize(office)
    @office = office
  end

  def update(user_ids)
    @office.user_ids = @office.ddfip.users.where(id: user_ids).pluck(:id)
    true
  end
end
