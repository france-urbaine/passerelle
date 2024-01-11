# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportsController do
  it { expect(get:    "/signalements").to route_to("reports#index") }
  it { expect(post:   "/signalements").to route_to("reports#create") }
  it { expect(patch:  "/signalements").to be_unroutable }
  it { expect(delete: "/signalements").to route_to("reports#destroy_all") }

  it { expect(get:    "/signalements/new").to       route_to("reports#new") }
  it { expect(get:    "/signalements/edit").to      be_unroutable }
  it { expect(get:    "/signalements/remove").to    route_to("reports#remove_all") }
  it { expect(get:    "/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/undiscard").to route_to("reports#undiscard_all") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("reports#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("reports#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("reports#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    route_to("reports#remove", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to route_to("reports#undiscard", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit/situation_majic").to route_to("reports#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", form: "situation_majic") }
  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit/unknown").to         route_to("reports#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", form: "unknown") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment/remove").to route_to("reports/assignments#remove", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment/edit").to route_to("reports/assignments#edit", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment").to route_to("reports/assignments#update", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(put:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment").to route_to("reports/assignments#update", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/assignment").to route_to("reports/assignments#destroy", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial/remove").to route_to("reports/denials#remove", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial/edit").to route_to("reports/denials#edit", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial").to route_to("reports/denials#update", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(put:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial").to route_to("reports/denials#update", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/denial").to route_to("reports/denials#destroy", report_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
