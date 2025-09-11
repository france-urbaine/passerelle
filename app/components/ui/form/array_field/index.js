import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template"];

  addEmptyInput(event) {
    this._cloneTemplate()
  }

  removeInput(event) {
    event.target.closest(".flex").remove()
  }

  _cloneTemplate () {
    let content = this.templateTarget.innerHTML

    this.templateTarget.insertAdjacentHTML("beforebegin", content)
  }
}
