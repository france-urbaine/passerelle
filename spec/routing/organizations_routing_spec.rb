# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationsController do
  it { expect(get:    "/organisations").to route_to("organizations#index") }
  it { expect(post:   "/organisations").to be_unroutable }
  it { expect(patch:  "/organisations").to be_unroutable }
  it { expect(delete: "/organisations").to be_unroutable }

  it { expect(get:    "/organisations/new").to       be_unroutable }
  it { expect(get:    "/organisations/edit").to      be_unroutable }
  it { expect(get:    "/organisations/remove").to    be_unroutable }
  it { expect(get:    "/organisations/undiscard").to be_unroutable }
  it { expect(patch:  "/organisations/undiscard").to be_unroutable }

  it { expect(get:    "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(post:   "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(delete: "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
end
