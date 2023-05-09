import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["officesFormBlock", "officesCheckboxesFrame"]
  static values  = {
    "officesUrl": String
  }

  connect() {}

  updateServices (event) {
    const value = JSON.parse(event.target.value)

    if (value && value.type == "DDFIP") {
      let url = this.officesUrlValue
      url += (url.includes("?") ? "&" : "?")
      url += ("ddfip_id=" + value.id)

      this.officesFormBlockTarget.classList.remove("hidden")
      this.officesCheckboxesFrameTarget.src = url
    } else {
      this.officesFormBlockTarget.classList.add("hidden")
      this.officesCheckboxesFrameTarget.src = null
    }
  }
}
