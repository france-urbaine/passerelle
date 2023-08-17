import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  connect() {}

  check (event) {
    const value = event.target.value

    if (value) {
      this.element.classList.add("password-field--checked")
      this.element.classList.remove("password-field--empty")
      this.frameTarget.src = "/password/strength_test?password=" + encodeURIComponent(value)
    } else {
      this.element.classList.add("password-field--empty")
      this.element.classList.remove("password-field--checked")
      this.frameTarget.src = null
      this.frameTarget.innerHTML = ""
    }
  }
}
