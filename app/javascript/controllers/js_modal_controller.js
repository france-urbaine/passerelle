import { Controller } from "@hotwired/stimulus"
import { useTransition } from 'stimulus-use'

// FIXME: The following controller is temporary. It should be deleted once the search system has been finalized.
export default class extends Controller {
  static targets = ["content"]

  connect () {
    useTransition(
      this, {
        element: this.contentTarget,
        transitioned: false,
    })
  }

  keydown (event) {
    if (event.key == "Escape") this.close(event)
  }

  open (event) {
    if (event) event.preventDefault()
    this.enter()
  }

  close (event) {
    if (event) event.preventDefault()
    this.leave()
  }
}
