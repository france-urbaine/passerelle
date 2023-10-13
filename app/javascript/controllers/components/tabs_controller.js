import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "tab"]

  initialize() {
    this.hideAllTabs = this.hideAllTabs.bind(this)
    this.showTab = this.showTab.bind(this)
  }

  connect() {
    if (this.anchor) {
      this.hideAllTabs()
      this.showTab(this.anchor)
    }
  }

  select(event) {
    this.hideAllTabs()
    this.showTab(event.params.id)
  }

  hideAllTabs() {
    this.tabTargets.forEach( function(child) {
      child.classList.remove("tabs__tab--current")
    } )
    this.contentTargets.forEach( function(child) {
      child.classList.add("hidden")
    } )
  }

  showTab(tabId) {
    this.tabTargets.forEach( function(child) {
      if ( child.children[0].attributes["href"].value == `#${tabId}`) {
        child.classList.add("tabs__tab--current")
      }
    } )
    this.element.querySelector(`#${tabId}`).classList.remove("hidden")
  }

  get anchor() {
    let anchor =  (document.URL.split('#').length > 1) ? document.URL.split('#')[1] : null
    if (this.element.querySelector(`[href='#${anchor}']`)) {
      return anchor
    }
  }
}
