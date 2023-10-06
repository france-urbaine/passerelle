# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController do
  it { expect(get:    "/api/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(post:   "/api/collectivites/9c6c00c4/transmissions").to route_to("api/transmissions#create", collectivity_id: "9c6c00c4") }
  it { expect(put:    "/api/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(patch:  "/api/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(delete: "/api/collectivites/9c6c00c4/transmissions").to be_unroutable }

  it { expect(get:    "/api/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(post:   "/api/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(put:    "/api/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(patch:  "/api/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(delete: "/api/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
end
