import { Controller } from "@hotwired/stimulus"
import { useTransition, useClickOutside, useHotkeys } from 'stimulus-use'
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["container"]
  static values = { backUrl: String }

  connect () {
    useTransition(this)
    useClickOutside(this, { element: this.containerTarget })
    useHotkeys(this, {
      hotkeys: {
        "esc": { handler: this.close }
      },
      filter: () => true
    })

    this.enter()
    this.clickOutside = this.close
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
