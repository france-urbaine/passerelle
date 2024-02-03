# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::EnrollmentsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/inscription").to route_to("users/enrollments#new") }
  it { expect(post:   "/inscription").to be_unroutable }
  it { expect(patch:  "/inscription").to be_unroutable }
  it { expect(delete: "/inscription").to be_unroutable }

  it { expect(get:    "/inscription/new").to       be_unroutable }
  it { expect(get:    "/inscription/edit").to      be_unroutable }
  it { expect(get:    "/inscription/remove").to    be_unroutable }
  it { expect(get:    "/inscription/undiscard").to be_unroutable }

  it { expect(get:    "/inscription/#{id}").to be_unroutable }
  it { expect(post:   "/inscription/#{id}").to be_unroutable }
  it { expect(patch:  "/inscription/#{id}").to be_unroutable }
  it { expect(delete: "/inscription/#{id}").to be_unroutable }
end
