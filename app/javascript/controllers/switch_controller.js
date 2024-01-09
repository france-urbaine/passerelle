import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target"]

  toggle (event) {
    const value = event.target.value + ""

    this.targetTargets.forEach((target) => {
      let targetValue = target.dataset.switchValue + ""
      let enabled = (value === targetValue)

      const separator = target.dataset.switchValueSeparator

      if (separator && separator.length > 0) {
        targetValue = targetValue.split(separator)
        enabled = targetValue.includes(value)
      }

      target.hidden = !enabled
      target.disabled = !enabled
    })
  }
}
