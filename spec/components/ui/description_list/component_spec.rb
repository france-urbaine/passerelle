# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::DescriptionList::Component do
  it "renders an attribute with a symbolized name and no content" do
    collectivity = create(:collectivity)

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:name)
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector("dt", text: "Nom de la collectivité")
          expect(row).to have_selector("dd", text: collectivity.name)
        end
      end
    end
  end

  it "renders an attribute with a symbolized name and a content block" do
    collectivity = create(:collectivity)

    expected_display = "#{collectivity.name} (500 personnes)"

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:name) { expected_display }
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector("dd", text: expected_display)
        end
      end
    end
  end

  it "renders an attribute with a string label" do
    collectivity = create(:collectivity, :with_users)
    collectivity.reload

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute("Utilisateurs") { collectivity.users_count.to_s }
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector("dt", text: "Utilisateurs")
          expect(row).to have_selector("dd", text: "1")
        end
      end
    end
  end

  it "renders an attribute with an action button" do
    collectivity = create(:collectivity)

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:name) do |attribute|
        collectivity.name
        attribute.with_action("Supprimer", "/", icon: "trash")
      end
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector("dd") do |dd|
            expect(dd).to have_selector("a.button", text: "Supprimer")
          end
        end
      end
    end
  end

  it "renders an attribute with a reference" do
    collectivity = create(:collectivity, name: "Toulouse")

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:name) do |attribute|
        collectivity.name
        attribute.with_reference do
          "Département : 31"
        end
      end
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row--with-reference")
      end
    end
  end

  it "renders an attribute with a nil content" do
    collectivity = create(:collectivity, contact_first_name: nil)

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:contact_first_name)
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector("dd") do |dd|
            expect(dd).to have_no_selector("span", text: "")
          end
        end
      end
    end
  end

  it "renders an attribute with no content" do
    collectivity = create(:collectivity, contact_first_name: "  ")

    render_inline described_class.new(collectivity) do |list|
      list.with_attribute(:contact_first_name)
    end

    expect(page).to have_selector(".card") do |card|
      expect(card).to have_selector("dl.description-list") do |description_list|
        expect(description_list).to have_selector(".description-list__row") do |row|
          expect(row).to have_selector(".description-list__details:empty")
        end
      end
    end
  end
end
