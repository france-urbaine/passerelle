# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::CollectivitiesController, :api do
  it { expect(get:    "http://api.example.com/collectivites").to route_to("api/collectivities#index") }
  it { expect(post:   "http://api.example.com/collectivites").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites").to be_unroutable }

  it { expect(get:    "http://api.example.com/collectivites/9c6c00c4").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/9c6c00c4").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites/9c6c00c4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/9c6c00c4").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/9c6c00c4").to be_unroutable }
end
