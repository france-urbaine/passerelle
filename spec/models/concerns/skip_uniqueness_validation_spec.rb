# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkipUniquenessValidation do
  subject(:record) { Publisher.new }

  it { expect(record).to respond_to(:skip_uniqueness_validation) }
  it { expect(record).to respond_to(:skip_uniqueness_validation=) }
  it { expect(record).to respond_to(:skip_uniqueness_validation!) }
  it { expect(record).to respond_to(:skip_uniqueness_validation?) }
  it { expect(record).to respond_to(:skip_uniqueness_validation_of_attribute?) }
  it { expect(record).to respond_to(:skip_uniqueness_validation_of_name?) }

  it "skips uniqueness validation of an attribute when it isn't changing" do
    record = create(:publisher)
    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "skips uniqueness validation of an attribute when any other attribute is changing" do
    record = create(:publisher)
    record.siren = "123456789"

    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "doesn't skip uniqueness validation of an attribute of an new record" do
    record = build(:publisher)

    expect(record.skip_uniqueness_validation_of_name?).to be(false)
  end

  it "doesn't skip uniqueness validation of an attribute when it's changing" do
    record = create(:publisher)
    record.name = "New publisher name"

    expect(record.skip_uniqueness_validation_of_name?).to be(false)
  end

  it "skips uniqueness validation of an attribute when it's explicitely asked" do
    record = create(:publisher)
    record.skip_uniqueness_validation!

    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "skips uniqueness validation of an attribute wehn the record is already discarded" do
    record = create(:publisher, :discarded)

    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "skips uniqueness validation of an attribute when it's changing but record is already discarded" do
    record = create(:publisher, :discarded)
    record.name = "New publisher name"

    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "skips uniqueness validation of an attribute when it's changing but record will be discarded" do
    record = create(:publisher)
    record.name = "New publisher name"
    record.discarded_at = Time.current

    expect(record.skip_uniqueness_validation_of_name?).to be(true)
  end

  it "doesn't skip uniqueness validation of an attribute when record will be undiscarded" do
    record = create(:publisher, :discarded)
    record.discarded_at = nil

    expect(record.skip_uniqueness_validation_of_name?).to be(false)
  end

  it "doesn't skip uniqueness validation of an attribute it's changing and record will be undiscarded" do
    record = create(:publisher, :discarded)
    record.name = "New publisher name"
    record.discarded_at = nil

    expect(record.skip_uniqueness_validation_of_name?).to be(false)
  end
end
