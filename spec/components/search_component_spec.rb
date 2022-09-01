# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchComponent, type: :component do
  subject(:component) { described_class.new("Rechercher...") }

  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) do
      render_inline(component)
    end
  end

  it do
    expect(rendered_content).to eq(clean_template(<<~HTML))
      <form autocomplete="off" class="search" data-turbo-frame="_top">
        <label class="form-block">
          <div class="form-block__label--hiden">Rechercher...</div>
          <div class="form-block__input">
            <div class="form-block__input-icon">
              <svg aria-hidden="true">
                <use href="#search-icon" />
              </svg>
            </div>
            <input name="search" placeholder="Rechercher..." type="search" />
          </div>
        </label>
      </form>
    HTML
  end

  context "with parameters" do
    let(:current_path) { "/communes?search=Pyr%C3%A9n%C3%A9es&order=-departement&page=2" }

    it do
      expect(rendered_content).to eq(clean_template(<<~HTML))
        <form autocomplete="off" class="search" data-turbo-frame="_top">
          <label class="form-block">
            <div class="form-block__label--hiden">Rechercher...</div>
            <div class="form-block__input">
              <div class="form-block__input-icon">
                <svg aria-hidden="true">
                  <use href="#search-icon" />
                </svg>
              </div>
              <input name="search" placeholder="Rechercher..." type="search" value="Pyrénées" />
            </div>
          </label>
          <input type="hidden" name="order" value="-departement" autocomplete="off">
        </form>
      HTML
    end
  end
end
