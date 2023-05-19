# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::EnrollmentsController do
  it { expect(get:    "/inscription").to be_unroutable }
  it { expect(post:   "/inscription").to be_unroutable }
  it { expect(patch:  "/inscription").to be_unroutable }
  it { expect(delete: "/inscription").to be_unroutable }

  it { expect(get:    "/inscription/new").to       route_to("users/enrollments#new") }
  it { expect(get:    "/inscription/edit").to      be_unroutable }
  it { expect(get:    "/inscription/remove").to    be_unroutable }
  it { expect(get:    "/inscription/undiscard").to be_unroutable }

  it { expect(get:    "/inscription/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/inscription/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/inscription/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/inscription/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
