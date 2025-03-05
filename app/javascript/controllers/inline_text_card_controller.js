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
        console.log(`Text card: set ID from element to ${cardId}`);
      } else {
        console.warn('Text card: Could not extract card ID from element', this.element);
      }
    } else {
      console.log(`Text card: using provided ID ${this.cardIdValue}`);
    }

    // Track original content to detect changes
    this.originalTitle = this.titleTarget.textContent.trim();
    this.originalContent = this.contentTarget ? this.contentTarget.textContent.trim() : '';

    // Set up change detection on focusout
    this.titleTarget.addEventListener('focusout', this.checkForChanges.bind(this));
    if (this.hasContentTarget) {
      this.contentTarget.addEventListener('focusout', this.checkForChanges.bind(this));
    }
    
    // Also add keyup events to detect changes as they type
    this.titleTarget.addEventListener('keyup', this.debounce(() => this.checkForChanges(), 500).bind(this));
    if (this.hasContentTarget) {
      this.contentTarget.addEventListener('keyup', this.debounce(() => this.checkForChanges(), 500).bind(this));
    }
  }
  
  // Helper method to debounce function calls
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  // Check if content has changed and register the change if so
  checkForChanges() {
    if (!this.titleTarget) {
      console.warn("Title target not found");
      return;
    }
    
    const newTitle = this.titleTarget.textContent.trim();
    const newContent = this.hasContentTarget ? this.contentTarget.textContent.trim() : '';
    
    const changes = {};
    let hasChanges = false;
    
    if (newTitle !== this.originalTitle) {
      changes.title = newTitle;
      hasChanges = true;
      console.log(`Text card ${this.cardIdValue}: title changed from "${this.originalTitle}" to "${newTitle}"`);
    }
    
    if (this.hasContentTarget && newContent !== this.originalContent) {
      changes.content = newContent;
      hasChanges = true;
      console.log(`Text card ${this.cardIdValue}: content changed`);
    }
    
    if (hasChanges) {
      // Make sure cardId is a string
      const cardId = String(this.cardIdValue);
      
      if (!cardId) {
        console.warn("No card ID available for change event");
        return;
      }
      
      // Dispatch an event to the portfolio controller to track this change
      const event = new CustomEvent('card:change', {
        bubbles: true,
        detail: {
          cardId: cardId,
          changes: changes
        }
      });
      
      console.log(`Text card ${this.cardIdValue}: dispatching change event`, event);
      
      this.element.dispatchEvent(event);
      
      // Don't update originals yet - we'll update them when saved
      // this.originalTitle = newTitle;
      // if (this.hasContentTarget) {
      //   this.originalContent = newContent;
      // }
    }
  }

  // Method to update the original values after a successful save
  updateOriginals() {
    this.originalTitle = this.titleTarget.textContent.trim();
    if (this.hasContentTarget) {
      this.originalContent = this.contentTarget.textContent.trim();
    }
    console.log(`Text card ${this.cardIdValue}: updated original values`);
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
        this.updateOriginals();
      })
      .catch(error => {
        console.error("Error updating card:", error);
      });
  }
}
