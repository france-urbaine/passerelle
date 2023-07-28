# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::UpdatesController do
  it { expect(get:    "/territoires/mise-a-jour").to route_to("territories/updates#edit") }
  it { expect(post:   "/territoires/mise-a-jour").to be_unroutable }
  it { expect(patch:  "/territoires/mise-a-jour").to route_to("territories/updates#update") }
  it { expect(delete: "/territoires/mise-a-jour").to be_unroutable }

  it { expect(get:    "/territoires/mise-a-jour/new").to       be_unroutable }
  it { expect(get:    "/territoires/mise-a-jour/edit").to      be_unroutable }
  it { expect(get:    "/territoires/mise-a-jour/remove").to    be_unroutable }
  it { expect(get:    "/territoires/mise-a-jour/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/mise-a-jour/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/mise-a-jour/9c6c00c4").to be_unroutable }
  it { expect(post:   "/territoires/mise-a-jour/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/territoires/mise-a-jour/9c6c00c4").to be_unroutable }
  it { expect(delete: "/territoires/mise-a-jour/9c6c00c4").to be_unroutable }
end
