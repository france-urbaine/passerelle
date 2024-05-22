import { Controller } from "@hotwired/stimulus"
import { Autocomplete } from "stimulus-autocomplete"

export default class extends Autocomplete {
  connect () {
    super.connect()
    this.element.classList.remove("hidden")
  }

  optionsForFetch () {
    return {
      headers: {
        "Accept-Variant": "Autocomplete",
        "X-Requested-With": "XMLHttpRequest"
      }
    }
  }
}
