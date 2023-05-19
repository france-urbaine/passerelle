# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::ConfirmationsController do
  it { expect(get:    "/confirmation").to route_to("users/confirmations#show") }
  it { expect(post:   "/confirmation").to route_to("users/confirmations#create") }
  it { expect(patch:  "/confirmation").to be_unroutable }
  it { expect(delete: "/confirmation").to be_unroutable }

  it { expect(get:    "/confirmation/new").to       route_to("users/confirmations#new") }
  it { expect(get:    "/confirmation/edit").to      be_unroutable }
  it { expect(get:    "/confirmation/remove").to    be_unroutable }
  it { expect(get:    "/confirmation/undiscard").to be_unroutable }

  it { expect(get:    "/confirmation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/confirmation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/confirmation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/confirmation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
