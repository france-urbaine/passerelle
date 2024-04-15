import { Controller } from "@hotwired/stimulus"

// FIXME: The following controller is temporary. It should be deleted once the search system has been finalized.
export default class ModalCallController extends Controller {
  static targets = ["modal"]

  async open (event) {
    this.modalTarget.removeAttribute("hidden")
    this.modalTarget.removeAttribute("aria-hidden")

    const modalController = this.application.getControllerForElementAndIdentifier(this.modalTarget, "modal")
    modalController.transitioned = false
    modalController.enter()
  }

  close (event) {
    if (event) event.preventDefault()

    this.modalTarget.setAttribute("hidden", true)
    this.modalTarget.setAttribute("aria-hidden", true)
  }
}
