import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "target"]

  initialize () {
    this.toggle = this.toggle.bind(this)
  }

  connect() {
    if (this.hasInputTarget) this.inputTarget.addEventListener("change", this.toggle)
  }

  disconnect () {
    if (this.hasInputTarget) this.inputTarget.removeEventListener('change', this.toggle)
  }

  toggle () {
    const value = this.inputTarget.value + ""

    this.targetTargets.forEach((target) => {
      let targetValue = target.dataset.switchValue + ""
      let enabled = (value === targetValue)

      const separator = target.dataset.switchValueSeparator

      if (separator && separator.length > 0) {
        targetValue = targetValue.split(separator)
        enabled = targetValue.includes(value)
      }

      target.hidden = !enabled
      target.querySelectorAll("input, select, textarea").forEach((input) => {
        input.disabled = !enabled
      })
    })
  }
}
