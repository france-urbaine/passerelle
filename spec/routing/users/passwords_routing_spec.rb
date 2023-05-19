# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::PasswordsController do
  it { expect(get:    "/password").to be_unroutable }
  it { expect(post:   "/password").to route_to("users/passwords#create") }
  it { expect(patch:  "/password").to route_to("users/passwords#update") }
  it { expect(delete: "/password").to be_unroutable }

  it { expect(get:    "/password/new").to       route_to("users/passwords#new") }
  it { expect(get:    "/password/edit").to      route_to("users/passwords#edit") }
  it { expect(get:    "/password/remove").to    be_unroutable }
  it { expect(get:    "/password/undiscard").to be_unroutable }

  it { expect(get:    "/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
