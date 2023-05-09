# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users nested under collectivities" do
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("users#index", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("users#create", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("users#destroy_all", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/new").to       route_to("users#new", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/remove").to    route_to("users#remove_all", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to route_to("users#undiscard_all", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
