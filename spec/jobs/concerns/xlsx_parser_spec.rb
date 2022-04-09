# frozen_string_literal: true

require "rails_helper"

RSpec.describe XLSXParser do
  subject(:call) { XLSXParser.call(path, sheet, offset:) }

  let(:path)   { file_fixture("communes.xlsx") }
  let(:sheet)  { "COM" }
  let(:offset) { 5 }

  it { expect(call).to be_an(Enumerator) }
  it { expect(call.to_a[0]).to include({ "CODGEO" => "01001", "EPCI" => "200069193", "LIBGEO" => "L'Abergement-Clémenciat" }) }
  it { expect(call.to_a[2]).to include({ "CODGEO" => "29155", "EPCI" => "ZZZZZZZZZ", "LIBGEO" => "Ouessant" }) }
end
