import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "cardsContainer", // The place where existing + new card forms go
    "textCardTemplate",
    "imageCardTemplate",
    "jobCardTemplate",
    "linkCardTemplate"
  ]

  addTextCard(event) {
    event.preventDefault()
    this._addCard(this.textCardTemplateTarget)
  }

  addImageCard(event) {
    event.preventDefault()
    this._addCard(this.imageCardTemplateTarget)
  }

  addJobCard(event) {
    event.preventDefault()
    this._addCard(this.jobCardTemplateTarget)
  }

  addLinkCard(event) {
    event.preventDefault()
    this._addCard(this.linkCardTemplateTarget)
  }

  _addCard(template) {
    // Clone the hidden template's HTML
    const clone = template.innerHTML
    // We need a unique index so Rails treats each group of fields as distinct
    const uniqueIndex = new Date().getTime() // or a global counter
    // Replace placeholder "NEW_RECORD" with the unique index
    const newFields = clone.replace(/NEW_RECORD/g, uniqueIndex)

    // Insert into the .cardsContainerTarget
    if (this.cardsContainerTarget.lastElementChild) {
      // Insert newFields before the last element (making it the penultimate)
      this.cardsContainerTarget.lastElementChild.insertAdjacentHTML("beforebegin", newFields);
    } else {
      // Fallback if the container is empty
      this.cardsContainerTarget.insertAdjacentHTML("beforeend", newFields);
    }
    }
}
