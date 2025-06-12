import { Controller } from "@hotwired/stimulus"

export default class SwitchFormController extends Controller {
  static targets = ["empty", "show", "hide"]

  update(event) {
    let updatedValues = []

    if (event.target.type == "checkbox") {
      updatedValues = Array.from(document.querySelectorAll("input[name='" + event.target.name + "']:not(:disabled)"))
        .filter(input => input.checked)
        .map(input => String(input.value))

    } else if (event.target.type == "select-multiple") {
      updatedValues = Array.from(event.target.selectedOptions)
        .map(option => String(option.value))

    } else {
      updatedValues = [String(event.target.value)]
    }

    const group = event.params.group
    const empty = !updatedValues.length || (updatedValues.length == 1 && updatedValues[0] === "")

    this.emptyTargets.forEach(target => {
      if (this.targetMatchGroup(target, group)) {
        target.hidden   = !empty
        target.disabled = !empty
      }
    })

    this.showTargets.forEach(target => {
      if (this.targetMatchGroup(target, group)) {
        const match = this.targetMatchValues(target, updatedValues)

        target.hidden   = !match
        target.disabled = !match
      }
    })

    this.hideTargets.forEach(target => {
      if (this.targetMatchGroup(target, group)) {
        const match = this.targetMatchValues(target, updatedValues)

        target.hidden   = match
        target.disabled = match
      }
    })
  }

  targetMatchGroup(target, group) {
    return !group || group === target.dataset.switchFormTargetGroup
  }

  targetMatchValues(target, updatedValues) {
    const targetValues = this.getTargetValues(target)

    return targetValues.some(value => updatedValues.includes(value))
  }

  getTargetValues(target) {
    if (target.dataset.switchFormTargetValue !== undefined) {
      return [target.dataset.switchFormTargetValue + ""]
    } else if (target.dataset.switchFormTargetValues !== undefined) {
      return JSON.parse(target.dataset.switchFormTargetValues).map(String)
    } else {
      return []
    }
  }
}
