import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static classes = ["toggle"]
  static values  = {
    attribute:   { type: String, default: "hidden" },
    revertDelay: { type: Number }
  }

  connect () {}

  toggle (event) {
    if (this.preventFromRunning) { return }

    this.itemTargets.forEach((item) => {
      if (this.attributeValue == "class") {
        item.classList.toggle(...this.toggleClasses)
      } else {
        item.toggleAttribute(this.attributeValue)
      }
    })

    if (event?.params?.revertDelay) {
      this.preventFromRunning = true

      setTimeout(() => {
        this.preventFromRunning = false
        this.toggle()
      }, event.params.revertDelay)
    }
  }

  setPreventFromRunning(value) {
    this.preventFromRunning = value
  }
}
