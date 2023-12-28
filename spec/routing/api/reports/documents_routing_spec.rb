# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Reports::DocumentsController, :api do
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/9c6c00c4/documents").to route_to("api/reports/documents#create", report_id: "9c6c00c4") }
  it { expect(patch:  "http://api.example.com/signalements/9c6c00c4/documents").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/9c6c00c4/documents").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/new").to       be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/edit").to      be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/remove").to    be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/undiscard").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/9c6c00c4/documents/undiscard").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/undiscard").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/file.pdf").to  be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/9c6c00c4/documents/b12170f4/image.png").to be_unroutable }
end
