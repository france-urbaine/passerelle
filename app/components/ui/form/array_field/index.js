import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template"];

  connect () {
    super.connect()
  }

  addEmptyInput(event) {
    if (!this._hasEmptyInputs()) {
      this._cloneTemplate()
    }
  }

  removeEmptyInput(event) {
    if (!event.target.value) {
      event.target.remove()
    }
  }

  _hasEmptyInputs () {
    for (let item of this.element.children) {
      if (item.tagName == "INPUT" && !item.value) {
        return true
      }
    }
    return false
  }

  _cloneTemplate () {
    let content = this.templateTarget.innerHTML

    this.templateTarget.insertAdjacentHTML("beforebegin", content)
  }
}
