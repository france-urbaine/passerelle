import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    console.log(this.tabTargets)
    console.log(this.panelTargets)
  }

  select(event) {
    const id = event.params.id

    this.tabTargets.forEach((tab) => {
      if (tab.id == id) {
        tab.classList.add("tabs__tab--current")
        tab.setAttribute("aria-selected", true)
      } else {
        tab.classList.remove("tabs__tab--current")
        tab.setAttribute("aria-selected", false)
      }
    })

    this.panelTargets.forEach((panel) => {
      if (panel.id == id + "-panel") {
        panel.hidden = false
      } else {
        panel.hidden = true
      }
    })
  }
}
