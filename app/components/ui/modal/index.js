import { Controller } from "@hotwired/stimulus"
import { useTransition } from 'stimulus-use'

export default class ModalController extends Controller {
  static targets = ["content"]

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
  }
}
