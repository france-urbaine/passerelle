# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportsController, :api do
  it { expect(get:    "http://api.example.com/signalements").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/9c6c00c4").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/9c6c00c4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/9c6c00c4").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/9c6c00c4").to be_unroutable }
end
