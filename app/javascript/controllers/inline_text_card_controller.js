// app/javascript/controllers/inline_text_card_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "content"]
  static values = {
    url: String // /users/:user_id/cards/:id
  }

  save(event) {
    event.preventDefault()

    // Grab the current text from the contenteditable elements:
    const newTitle = this.titleTarget.textContent.trim()
    const newContent = this.contentTarget.textContent.trim()

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        card: {
          title: newTitle,
          content: newContent
        }
      })
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Network error: ${response.status} ${response.statusText}`)
        }
        return response.json()
      })
      .then(data => {
        console.log("Card updated successfully:", data)
        // Optionally show a confirmation, or re-render the partial if needed
      })
      .catch(error => {
        console.error("Error updating card:", error)
      })
  }
}
