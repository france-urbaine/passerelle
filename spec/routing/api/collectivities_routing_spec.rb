# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::CollectivitiesController" do
  it { expect(get:    "/api/collectivites").to be_unroutable }
  it { expect(post:   "/api/collectivites").to be_unroutable }
  it { expect(put:    "/api/collectivites").to be_unroutable }
  it { expect(patch:  "/api/collectivites").to be_unroutable }
  it { expect(delete: "/api/collectivites").to be_unroutable }

  it { expect(get:    "/api/collectivites/9c6c00c4").to be_unroutable }
  it { expect(post:   "/api/collectivites/9c6c00c4").to be_unroutable }
  it { expect(put:    "/api/collectivites/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/api/collectivites/9c6c00c4").to be_unroutable }
  it { expect(delete: "/api/collectivites/9c6c00c4").to be_unroutable }
end
