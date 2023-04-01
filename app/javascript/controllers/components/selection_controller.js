import { Controller } from "@hotwired/stimulus"
import { useHotkeys } from "stimulus-use/hotkeys"

export default class extends Controller {
  static targets = ["checkall", "checkbox", "frame"]

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

    const checkboxes   = this.checkboxTargets
    const checkedboxes = this.checkboxTargets.filter(checkbox => checkbox.checked)

    this.checkallTarget.checked       = checkedboxes.length > 0
    this.checkallTarget.indeterminate = checkedboxes.length > 0 && checkedboxes.length < checkboxes.length
  }

  disconnect () {
    this.checkallTarget.removeEventListener('change', this.toggleAll)
    this.checkboxTargets.forEach(checkbox => checkbox.removeEventListener('change', this.toggleBox))
  }

  toggleAll (event) {
    if (event) event.preventDefault()

    this.switchAll(event.target.checked)
    this.refresh()
  }

  checkAll () {
    this.switchAll(true)
    this.refresh()
  }

  uncheckAll () {
    this.switchAll(false)
    this.refresh()
  }

  switchAll (checked) {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked
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
    const checkboxes = this.checkboxTargets
    const checkedIds = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    this.checkallTarget.checked       = checkedIds.length > 0
    this.checkallTarget.indeterminate = checkedIds.length > 0 && checkedIds.length < checkboxes.length

    this.dispatch(checkedIds.length > 0 ? "checked" : "unchecked")

    if (this.hasFrameTarget) {
      const frameHref = window.location.href
      const parsedUrl = new URL(frameHref)

      parsedUrl.searchParams.delete("ids")
      parsedUrl.searchParams.delete("ids[]")
      checkedIds.forEach(id => parsedUrl.searchParams.append("ids[]", id))

      this.frameTarget.src = parsedUrl.href
    }
  }

  triggerInputEvent (checkbox) {
    const event = new Event("input", { bubbles: false, cancelable: true })
    checkbox.dispatchEvent(event)
  }
}
