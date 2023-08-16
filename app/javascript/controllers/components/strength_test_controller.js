import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  connect() {}

  check (event) {
    const value = event.target.value

    if (value) {
      this.frameTarget.src = "/password/strength_test?password=" + value
    } else {
      this.frameTarget.src = null
      this.frameTarget.innerHTML = ""
    }

  }
}
