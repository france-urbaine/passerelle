import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  connect() {}

  check (event) {
    const value = event.target.value

    this.frameTarget.src = "/password/strength_test?password=" + value
  }
}
