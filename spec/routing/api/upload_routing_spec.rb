# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::UploadsController, :api do
  it { expect(get:    "http://api.example.com/documents").to be_unroutable }
  it { expect(post:   "http://api.example.com/documents").to route_to("api/uploads#create") }
  it { expect(put:    "http://api.example.com/documents").to be_unroutable }
  it { expect(patch:  "http://api.example.com/documents").to be_unroutable }
  it { expect(delete: "http://api.example.com/documents").to be_unroutable }

  it { expect(get:    "http://api.example.com/documents/9c6c00c4").to be_unroutable }
  it { expect(post:   "http://api.example.com/documents/9c6c00c4").to be_unroutable }
  it { expect(put:    "http://api.example.com/documents/9c6c00c4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/documents/9c6c00c4").to be_unroutable }
  it { expect(delete: "http://api.example.com/documents/9c6c00c4").to be_unroutable }
end
