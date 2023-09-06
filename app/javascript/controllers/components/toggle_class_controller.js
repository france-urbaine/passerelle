import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static classes = [ "toggle" ]

  initialize () {
    this.preventFromRunning = false
  }

  connect () { }

  toggle (event) {
    if (this.preventFromRunning) { return }

    this.itemTargets.forEach((item) => {
      item.classList.toggle(...this.toggleClasses)
    })

    if (event?.params?.revertAfterDelay) {
      this.setPreventFromRunning(true)

      setTimeout(this.setPreventFromRunning.bind(this), event.params.revertAfterDelay, false)
      setTimeout(this.toggle.bind(this), event.params.revertAfterDelay)
    }
  }

  setPreventFromRunning(value) {
    this.preventFromRunning = value
  }
}
