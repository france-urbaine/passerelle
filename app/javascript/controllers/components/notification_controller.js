import { Controller } from "@hotwired/stimulus"
import { useTransition } from "stimulus-use"

export default class extends Controller {
  static values = { delay: Number }

  connect () {
    useTransition(this)
    this.enter()
    if (this.delayValue) this.timeout = setTimeout(this.hide.bind(this), this.delayValue)
  }

  async hide (event) {
    if (event) event.preventDefault()
    if (this.timeout) clearTimeout(this.timeout)

    await this.leave()
    this.element.remove()
  }
}