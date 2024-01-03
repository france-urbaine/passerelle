import { Controller } from "@hotwired/stimulus"
import { useTransition } from "stimulus-use"

export default class DropdownController extends Controller {
  static targets = ["button", "menu"]

  connect () {
    useTransition(this, {
      element: this.menuTarget
    })
  }

  toggle () {
    this.opened = !this.opened
    this.opened ? this.enter() : this.leave()
    this.buttonTarget.setAttribute("aria-expanded", this.opened)
  }

  clickOutside (event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('hidden')) {
      this.toggle()
    }
  }
}
