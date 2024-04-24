import { Controller } from "@hotwired/stimulus"

export let controllerName = "tabs"
export default class TabsController extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.boundSync = this.sync.bind(this)
    document.addEventListener("tabs:sync", this.boundSync)
  }

  disconnect() {
    document.removeEventListener("tabs:sync", this.boundFindFoo)
  }

  select(event) {
    const id = event.params.id
    const sync = event.params.sync

    this.activate(id)
    if (sync) this.dispatch("sync", { detail: { syncWith: sync } })
  }

  sync ({ detail: { syncWith } }) {
    this.tabTargets.some((tab) => {
      if (tab.getAttribute("data-tabs-sync-param") == syncWith) {
        const id = tab.getAttribute("data-tabs-id-param")
        this.activate(id)

        return true
      } else {
        return false
      }
    })
  }

  activate (id) {
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
      if (panel.id == "panel_" + id) {
        panel.hidden = false
      } else {
        panel.hidden = true
      }
    })
  }
}
