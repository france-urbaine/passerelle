// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as ActiveStorage from "@rails/activestorage"

ActiveStorage.start()

// FIXME: Monkeypatch to allow to redirect the full page after submitting a form from a modal.
// see:
//  https://github.com/hotwired/turbo-rails/pull/367
//  https://github.com/hotwired/turbo/pull/863#issuecomment-1470184953
//
document.addEventListener("turbo:frame-missing", (event) => {
  if (event.detail.response.redirected) {
    event.preventDefault()
    event.detail.visit(event.detail.response)
  }
})

// FIXME: Monkeypatch to fix turbo issue of wrong turbo-frame
// see: https://github.com/hotwired/turbo/pull/579
//
document.addEventListener('turbo:before-fetch-request', (event) => {
  const targetTurboFrame = event.target.getAttribute('data-turbo-frame')
  const fetchTurboFrame = event.detail.fetchOptions.headers['Turbo-Frame']

  if (targetTurboFrame && targetTurboFrame != fetchTurboFrame && document.querySelector(`turbo-frame#${targetTurboFrame}`)) {
    event.detail.fetchOptions.headers['Turbo-Frame'] = targetTurboFrame;
  }
})
