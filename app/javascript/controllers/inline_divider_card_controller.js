import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["title"]
    static values = {
        url: String,
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
        
        // Set up change detection on focusout
        this.titleTarget.addEventListener('focusout', this.checkForChanges.bind(this));
    }
    
    // Check if content has changed and register the change if so
    checkForChanges() {
        const newTitle = this.titleTarget.textContent.trim();
        
        if (newTitle !== this.originalTitle) {
            // Dispatch an event to the portfolio controller to track this change
            const event = new CustomEvent('card:change', {
                bubbles: true,
                detail: {
                    cardId: this.cardIdValue,
                    changes: {
                        title: newTitle
                    }
                }
            });
            
            this.element.dispatchEvent(event);
            
            // Update original
            this.originalTitle = newTitle;
        }
    }
    
    // This method is still available for immediate saves if needed
    save(event) {
        event.preventDefault();
        const newTitle = this.titleTarget.textContent.trim();
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
                    title: newTitle
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
                // Update the original after a successful save
                this.originalTitle = newTitle;
            })
            .catch(error => {
                console.error("Error updating card:", error);
            });
    }
} 