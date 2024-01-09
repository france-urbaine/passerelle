import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    source: String
  }

  connect() {
    if (!(navigator.clipboard && window.isSecureContext)) {
      this.element.disabled = true
      this.element.firstChild.firstChild.innerHTML = "La copie du texte n'est pas disponible dans cet environnement."
    }
  }

  copy () {
    navigator.clipboard.writeText(this.sourceValue)
  }
}
