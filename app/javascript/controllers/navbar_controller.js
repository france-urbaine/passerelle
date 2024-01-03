import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minified", "expanded"]

  expand (event) {
    event.stopPropagation()
    this.minifiedTarget.setAttribute("aria-expanded", false)
    this.expandedTarget.setAttribute("aria-expanded", true)
  }

  minify (event) {
    event.stopPropagation()
    this.minifiedTarget.setAttribute("aria-expanded", true)
    this.expandedTarget.setAttribute("aria-expanded", false)
  }
}