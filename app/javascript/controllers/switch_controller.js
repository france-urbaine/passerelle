import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["showWhenEmpty", "hide", "show"]

  toggle(event) {
    const group = event.params.group
    const updatedValues = this.inputValues(event.target)
    const empty = !updatedValues.length || (updatedValues.length == 1 && updatedValues[0] === "")

    this.showWhenEmptyTargets.forEach(target => {
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

  inputValues(target) {
    if (target.type == "checkbox") {
      return Array.from(document.querySelectorAll("input[name='" + target.name + "']:not(:disabled)"))
        .filter(input => input.checked)
        .map(input => String(input.value))

    } else if (target.type == "select-multiple") {
      return Array.from(target.selectedOptions)
        .map(option => String(option.value))

    } else {
      return [String(target.value)]
    }
  }

  targetMatchGroup(target, group) {
    return !group || group === target.dataset.switchTargetGroup
  }

  targetMatchValues(target, updatedValues) {
    const targetValues = this.getTargetValues(target)

    return targetValues.some(value => updatedValues.includes(value))
  }

  getTargetValues(target) {
    const value = target.dataset.switchValue
    const values = target.dataset.switchValues
    const separator = target.dataset.switchValueSeparator

    if (separator && separator.length > 0 && value !== undefined) {
      return value.split(separator)
    } else if (value !== undefined) {
      return [value + ""]
    } else if (values !== undefined) {
      return JSON.parse(values).map(String)
    } else {
      return []
    }
  }
}
