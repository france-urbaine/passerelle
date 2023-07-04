import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["affectationInput", "habitation", "professionnel", "habitationInput", "professionnelInput"]
  static values = {
    affectationHabitation: Array,
    affectationProfessionnel: Array
  }

  connect() {
  }

  toggleAffectation() {
    const habitation    = this.affectationHabitationValue.includes(this.affectationInputTarget.value + "")
    const professionnel = this.affectationProfessionnelValue.includes(this.affectationInputTarget.value + "")

    this.habitationTargets.forEach((target) => target.hidden = !habitation)
    this.professionnelTargets.forEach((target) => target.hidden = !professionnel)

    this.habitationInputTargets.forEach((target) => target.disabled = !habitation)
    this.professionnelInputTargets.forEach((target) => target.disabled = !professionnel)
  }
}
