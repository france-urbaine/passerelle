import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input"];

  initialize () {
    this.onChangeBound = this.onChange.bind(this)
  }

  connect() {
    if (this.hasListTarget) {
      this.listElement = this.listTarget
    } else {
      this.listElement = this.createList()
    }

    this.element.addEventListener('change', this.onChangeBound)
  }

  disconnect() {
    this.element.removeEventListener("change", this.onChangeBound)
  }

  createList () {
    const list = document.createElement('ul')

    list.setAttribute("class", "direct-upload__list")
    list.setAttribute("data-direct-upload-field-target", "list")
    this.element.parentNode.insertBefore(list, this.element.nextSibling)

    return list
  }

  onChange (event) {
    Array.from(this.element.files).forEach((file) => {
      new DirectUploadController(this.element, this.listElement, file).start()
    })

    // Clear the selected files from the input
    this.element.value = null
  }
}

export class DirectUploadController {
  constructor(input, list, file) {
    this.input = input
    this.list = list
    this.file = file
    this.directUpload = new DirectUpload(file, this.url, this)
  }

  get url() {
    return this.input.getAttribute("data-direct-upload-url")
  }

  start () {
    const listItem = document.createElement('li')
    const filename = document.createElement('div')
    const progress = document.createElement('div')

    listItem.setAttribute("class", "direct-upload__list-item")
    progress.setAttribute("class", "direct-upload__progress")
    filename.textContent = this.file.name

    listItem.appendChild(filename)
    listItem.appendChild(progress)
    this.list.appendChild(listItem)

    this.progress = progress

    const hiddenInput = document.createElement("input")
    hiddenInput.type = "hidden"
    hiddenInput.name = this.input.name
    this.input.insertAdjacentElement("beforebegin", hiddenInput)

    this.directUpload.create((error, blob) => {
      if (error) {
        hiddenInput.parentNode.removeChild(hiddenInput)
        this.progress.classList.add("direct-upload__progress--failed")
      } else {
        hiddenInput.value = blob.signed_id
        this.progress.classList.add("direct-upload__progress--complete")
      }
    })
  }

  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", (event) => {
      const progress = event.loaded / event.total * 100

      this.progress.style.width = `${progress}%`
    })
  }
}
