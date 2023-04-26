import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]
  static classes = ["selected"]

  initialize () {
    this.toggle = this.toggle.bind(this)
  }

  connect () {
    if (!this.hasCheckboxTarget) return

    this.checkboxTarget.addEventListener("change", this.toggle)
    this.checkboxTarget.addEventListener("input", this.toggle)
    this.toggle()
  }

  disconnect () {
    if (!this.hasCheckboxTarget) return

    this.checkboxTarget.removeEventListener("change", this.toggle)
    this.checkboxTarget.removeEventListener("input", this.toggle)
  }

  toggle () {
    this.element.classList[
      this.checkboxTarget.checked ? "add" : "remove"
    ](this.selectedClass)
  }
}
