// app/javascript/controllers/inline_text_card_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "content"]
  static values = {
    url: String, // /users/:user_id/cards/:id
    cardId: String
  }

  connect() {
    // Extract the card ID from the controller element's ID (card_123)
    if (!this.hasCardIdValue) {
      const elementId = this.element.id;
      const cardId = elementId ? elementId.replace('card_', '') : null;
      if (cardId) {
        this.cardIdValue = cardId;
      }
    }

    // Track original content to detect changes
    this.originalTitle = this.titleTarget.textContent.trim();
    this.originalContent = this.contentTarget ? this.contentTarget.textContent.trim() : '';

    // Set up change detection on focusout
    this.titleTarget.addEventListener('focusout', this.checkForChanges.bind(this));
    if (this.hasContentTarget) {
      this.contentTarget.addEventListener('focusout', this.checkForChanges.bind(this));
    }
  }

  // Check if content has changed and register the change if so
  checkForChanges() {
    const newTitle = this.titleTarget.textContent.trim();
    const newContent = this.hasContentTarget ? this.contentTarget.textContent.trim() : '';
    
    const changes = {};
    let hasChanges = false;
    
    if (newTitle !== this.originalTitle) {
      changes.title = newTitle;
      hasChanges = true;
    }
    
    if (this.hasContentTarget && newContent !== this.originalContent) {
      changes.content = newContent;
      hasChanges = true;
    }
    
    if (hasChanges) {
      // Dispatch an event to the portfolio controller to track this change
      const event = new CustomEvent('card:change', {
        bubbles: true,
        detail: {
          cardId: this.cardIdValue,
          changes: changes
        }
      });
      
      this.element.dispatchEvent(event);
      
      // Update originals
      this.originalTitle = newTitle;
      if (this.hasContentTarget) {
        this.originalContent = newContent;
      }
    }
  }

  // This method is still available for immediate saves if needed
  save(event) {
    event.preventDefault();

    // Grab the current text from the contenteditable elements:
    const newTitle = this.titleTarget.textContent.trim();
    const newContent = this.hasContentTarget ? this.contentTarget.textContent.trim() : '';

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

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
          throw new Error(`Network error: ${response.status} ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        console.log("Card updated successfully:", data);
        // Update the originals after a successful save
        this.originalTitle = newTitle;
        if (this.hasContentTarget) {
          this.originalContent = newContent;
        }
      })
      .catch(error => {
        console.error("Error updating card:", error);
      });
  }
}
