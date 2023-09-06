import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    source: String
  }

  connect() { }

  copy () {
    navigator.clipboard.writeText(this.sourceValue)
  }
}
