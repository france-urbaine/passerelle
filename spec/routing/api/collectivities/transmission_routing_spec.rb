# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController, :api do
  it { expect(get:    "http://api.example.com/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/9c6c00c4/transmissions").to route_to("api/transmissions#create", collectivity_id: "9c6c00c4") }
  it { expect(put:    "http://api.example.com/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/9c6c00c4/transmissions").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/9c6c00c4/transmissions").to be_unroutable }

  it { expect(get:    "http://api.example.com/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/9c6c00c4/transmissions/b12170f4").to be_unroutable }
end
