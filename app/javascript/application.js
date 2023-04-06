// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// FIXME: Waiting for https://github.com/hotwired/turbo-rails/pull/367 to be merged.
// It would allow to redirect the full page after submitting a form from a modal.
//
// This is a workaround fix from
// https://github.com/hotwired/turbo/pull/863#issuecomment-1470184953
//
document.addEventListener("turbo:frame-missing", function(event) {
  event.preventDefault()
  event.detail.visit(event.detail.response)
})