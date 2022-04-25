import { Controller } from "@hotwired/stimulus"
import { useTransition } from 'stimulus-use'
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["container"]
  static values = { backUrl: String }

  connect () {
    useTransition(this)
    this.enter()
  }

  keydown (event) {
    if (event.key == "Escape") this.close(event)
  }

  async close (event) {
    if (event) event.preventDefault()

    await this.leave()
    this.element.remove()

    if (this.backUrlValue) {
      Turbo.visit(this.backUrlValue, { action: "restore" })
    }
  }
}
