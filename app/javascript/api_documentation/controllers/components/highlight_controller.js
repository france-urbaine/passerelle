import { Controller } from "@hotwired/stimulus"
import hljs from 'highlight.js/lib/core'
import json from 'highlight.js/lib/languages/json'
import shell from 'highlight.js/lib/languages/shell'
import bash from 'highlight.js/lib/languages/bash'
import http from 'highlight.js/lib/languages/http'

export default class extends Controller {
  static values = {
    language: { type: String, default: 'json' }
  }

  connect () {
    console.log("3")
    let language = this.registerLanguage(this.languageValue)

    this.element.innerHTML = hljs.highlight(
      this.element.innerText,
      { language: language }
    ).value
  }

  registerLanguage (language) {
    switch(this.languageValue) {
      case 'shell':
        hljs.registerLanguage('bash', bash)
        hljs.registerLanguage('shell', shell)
        return 'shell'
      case 'http':
        hljs.registerLanguage('http', http)
        return 'http'
      default:
        hljs.registerLanguage('json', json)
        return 'json'
    }
  }
}
