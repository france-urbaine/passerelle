# frozen_string_literal: true

require "rails_helper"
require "fileutils"

RSpec.describe Unarchiver do
  subject(:call) { Unarchiver.call(path, "*.xlsx") }

  let(:path)    { Rails.root.join("tmp/test/unarchiver_test.zip") }
  let(:target)  { Rails.root.join("tmp/test/communes.xlsx") }
  let(:fixture) { file_fixture("communes.zip") }

  before do
    target.delete if target.exist?
    FileUtils.cp(fixture, path)
  end

  it { expect { call }.to change(target, :exist?).to(true) }
  it { expect(call).to eq(target) }
  it { expect(call.size).to be_positive }
end
