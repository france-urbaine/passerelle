# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::CheckboxesComponent, type: :component do
  it "renders checkboxes with a collection of records" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  type: "checkbox", with: users.first.id)
        expect(div).to have_unchecked_field(users.second.name, type: "checkbox", with: users.second.id)
        expect(div).to have_unchecked_field(users.third.name,  type: "checkbox", with: users.third.id)
      end
    end
  end

  it "renders checkboxes with a collection of records and custom properties" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users, value_method: :first_name, text_method: :first_name)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.first_name,  with: users.first.first_name)
        expect(div).to have_unchecked_field(users.second.first_name, with: users.second.first_name)
        expect(div).to have_unchecked_field(users.third.first_name,  with: users.third.first_name)
      end
    end
  end

  it "renders checkboxes with a collection of arrays" do
    users  = create_list(:user, 3)
    values = users.map { |o| [o.first_name, o.name] }

    render_inline described_class.new(:office, :user_ids, values)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  with: users.first.first_name)
        expect(div).to have_unchecked_field(users.second.name, with: users.second.first_name)
        expect(div).to have_unchecked_field(users.third.name,  with: users.third.first_name)
      end
    end
  end

  it "renders checkboxes with a collection of single values" do
    users  = create_list(:user, 3)
    values = users.map(&:name)

    render_inline described_class.new(:office, :user_ids, values)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  with: users.first.name)
        expect(div).to have_unchecked_field(users.second.name, with: users.second.name)
        expect(div).to have_unchecked_field(users.third.name,  with: users.third.name)
      end
    end
  end

  it "renders the checkboxes collection within a Stimulus controller" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection[data-controller='selection']")
  end

  it "renders checkboxes with an option to select all" do
    users = create_list(:user, 5)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection[data-controller='selection']") do |div|
      expect(div).to have_unchecked_field("Tout sélectionner", type: "checkbox")
    end
  end

  it "renders checkboxes without any option to select all when there is less than 5 options" do
    users = create_list(:user, 4)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection[data-controller='selection']") do |div|
      expect(div).not_to have_unchecked_field("Tout sélectionner")
    end
  end

  #   def default_input_methods
  #     case @collection
  #     in [ApplicationRecord, *]
  #       if @collection.first.respond_to?(:name)
  #         %i[id name]
  #       else
  #         %i[id to_s]
  #       end
  #     in [Array, *]
  #       %i[first second]
  #     else
  #       %i[to_s to_s]
  #     end
  #   end
  # end
end
