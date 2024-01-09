import { Controller } from "@hotwired/stimulus"

const targetValueAttribute = "data-selection-group-target-value"

export default class extends Controller {
  static targets = ["parent", "child"]

  initialize () {
    this.toggleGroup = this.toggleGroup.bind(this)
    this.toggleChild = this.toggleChild.bind(this)
  }

  connect () {
    this.parentTargets.forEach(checkbox => checkbox.addEventListener("change", this.toggleGroup))
    this.childTargets.forEach(checkbox => checkbox.addEventListener("change", this.toggleChild))
    this.refresh()
  }

  disconnect () {
    this.parentTargets.forEach(checkbox => checkbox.removeEventListener('change', this.toggleGroup))
    this.childTargets.forEach(checkbox => checkbox.removeEventListener('change', this.toggleChild))
  }

  toggleGroup (event) {
    if (event) event.preventDefault()

    const element     = event.target
    const targetValue = element.getAttribute(targetValueAttribute)

    this.switchAll(targetValue, element.checked)
    this.refresh()
  }

  switchAll (targetValue, checked) {
    this.childTargets.forEach((checkbox) => {
      if (checkbox.getAttribute(targetValueAttribute) == targetValue) {
        checkbox.checked = checked
        this.triggerInputEvent(checkbox)
      }
    })
  }

  toggleChild (event) {
    this.refresh()
  }

  refresh () {
    this.parentTargets.forEach((parent) => {
      const targetValue     = parent.getAttribute(targetValueAttribute)
      const children        = this.childTargets.filter(checkbox => checkbox.getAttribute(targetValueAttribute) == targetValue)
      const childrenChecked = children.filter(checkbox => checkbox.checked)

      parent.checked       = childrenChecked.length > 0
      parent.indeterminate = childrenChecked.length > 0 && childrenChecked.length < children.length

      this.dispatch(childrenChecked.length > 0 ? "checked" : "unchecked")
    })
  }

  triggerInputEvent (checkbox) {
    const event = new Event("input", { bubbles: false, cancelable: true })
    checkbox.dispatchEvent(event)
  }
}
