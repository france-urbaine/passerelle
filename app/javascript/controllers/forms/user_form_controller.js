import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["servicesFormBlock", "servicesCheckboxesFrame"]
  static values  = {
    "servicesUrl": String
  }

  connect() {}

  updateServices (event) {
    const value = JSON.parse(event.target.value)

    if (value && value.type == "DDFIP") {
      let url = this.servicesUrlValue
      url += (url.includes("?") ? "&" : "?")
      url += ("ddfip_id=" + value.id)

      this.servicesFormBlockTarget.classList.remove("hidden")
      this.servicesCheckboxesFrameTarget.src = url
    } else {
      this.servicesFormBlockTarget.classList.add("hidden")
      this.servicesCheckboxesFrameTarget.src = null
    }
  }
}
