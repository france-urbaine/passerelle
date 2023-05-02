# frozen_string_literal: true

class OfficeUsersForm
  extend ActiveModel::Naming

  def initialize(office)
    @office = office
  end

  def model_name
    @model_name ||= ActiveModel::Name.new(self, nil, "OfficeUsers")
  end

  def suggested_users
    @suggested_users ||= @office.ddfip.users.order(:created_at)
  end

  def user_ids
    @user_ids ||= @office.user_ids
  end
end
