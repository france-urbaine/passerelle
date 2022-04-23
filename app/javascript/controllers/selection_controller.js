import { Controller } from "@hotwired/stimulus"
import { useHotkeys } from 'stimulus-use'

export default class extends Controller {
  static targets = ["checkall", "checkbox"]

  initialize () {
    this.toggleAll = this.toggleAll.bind(this)
    this.toggleBox = this.toggleBox.bind(this)
  }

  connect () {
    useHotkeys(this, {
      hotkeys: {
        "*": {
          handler: this.keyPress,
          options: { keyup: true }
        }
      },
      filter: () => true
    })

    this.checkallTarget.addEventListener("change", this.toggleAll)
    this.checkboxTargets.forEach(checkbox => checkbox.addEventListener("change", this.toggleBox))
    this.refresh()
  }

  disconnect () {
    this.checkallTarget.removeEventListener('change', this.toggleAll)
    this.checkboxTargets.forEach(checkbox => checkbox.removeEventListener('change', this.toggleBox))
  }

  toggleAll (event) {
    if (event) event.preventDefault()

    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = event.target.checked
      this.triggerInputEvent(checkbox)
    })
  }

  toggleBox (event) {
    if (this.lastCheckbox && this.shiftPress) {
      const newIndex      = this.checkboxTargets.indexOf(event.target)
      const previousIndex = this.checkboxTargets.indexOf(this.lastCheckbox)
      const checkboxes    = newIndex < previousIndex ?
        this.checkboxTargets.slice(newIndex, previousIndex) :
        this.checkboxTargets.slice(previousIndex, newIndex)

      checkboxes.forEach((checkbox) => {
        if (checkbox != event.target) {
          checkbox.checked = event.target.checked
          this.triggerInputEvent(checkbox)
        }
      })
    }

    this.lastCheckbox = event.target
    this.refresh()
  }

  keyPress (event) {
    if (event.type == "keydown" && event.key == "Shift") this.shiftPress = true
    if (event.type == "keyup" && event.key == "Shift") this.shiftPress = false
  }

  refresh () {
    const checkboxCount   = this.checkboxTargets.length
    const checkedboxCount = this.checkboxTargets.filter(checkbox => checkbox.checked).length

    this.checkallTarget.checked       = checkedboxCount > 0
    this.checkallTarget.indeterminate = checkedboxCount > 0 && checkedboxCount < checkboxCount
  }

  triggerInputEvent (checkbox) {
    const event = new Event("input", { bubbles: false, cancelable: true })
    checkbox.dispatchEvent(event)
  }
}
