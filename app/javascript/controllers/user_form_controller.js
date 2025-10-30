import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["officesFormBlock", "officesCheckboxesFrame", "showIfDDFIP"]
  static values  = {
    "officesUrl": String
  }

  connect() {}

  updateServices (event) {
    const value = JSON.parse(event.target.value)
    const showIfDDFIP = new Array(...this.showIfDDFIPTargets, this.officesFormBlockTarget)

    if (value && value.type == "DDFIP") {
      let url = this.officesUrlValue
      url += (url.includes("?") ? "&" : "?")
      url += ("ddfip_id=" + value.id)

      this.officesCheckboxesFrameTarget.src = url
      showIfDDFIP.forEach((item) => {
        item.classList.remove("hidden")
        item.removeAttribute("hidden")
      })
    } else {
      this.officesCheckboxesFrameTarget.src = null
      showIfDDFIP.forEach((item) => {
        item.classList.add("hidden")
        item.setAttribute("hidden", "hidden")
      })
    }
  }
}
