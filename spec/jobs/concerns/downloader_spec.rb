# frozen_string_literal: true

require "rails_helper"

RSpec.describe Downloader do
  subject(:call) { Downloader.call(url) }

  let(:url)      { "http://example.com/some/path" }
  let(:location) { "http://example.com/redirection/downloader_test.zip" }
  let(:target)   { Rails.root.join("tmp/test/downloader_test.zip") }
  let(:fixture)  { file_fixture("communes.zip") }

  before do
    target.delete if target.exist?

    stub_request(:head, url)
      .to_return(status: 303, body: "", headers: { "Location" => location })

    stub_request(:head, location)
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, location)
      .to_return(status: 200, body: fixture)
  end

  it { expect { call }.to change(target, :exist?).to(true) }
  it { expect(call).to eq(target) }
  it { expect(call.size).to be_positive }
end
