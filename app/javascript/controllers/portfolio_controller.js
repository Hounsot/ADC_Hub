import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["actionBar", "addButton", "blur"];
    static values = {
    breakpoint: { type: Number, default: 600 },
    cardType: { type: String, default: "U_1/1" }, // Default card type
    sectionId: { type: String } // Add section ID value
  };

  connect() {
    console.log("Portfolio controller connected");
    this.pendingCardChanges = {}; // Store changes for cards that need to be saved
    
    // Make sure we're listening for card:change events
    this.element.addEventListener('card:change', this.registerCardChange.bind(this));
  }

  toggleActionBar(event) {
    event.preventDefault();
    
    // Get the clicked button and its parent action bar
    const button = event.currentTarget;
    const actionBar = button.closest('.W_AddCard').querySelector('.W_AddCardOptions');
    
    // Toggle visibility
    if (actionBar) {
      actionBar.classList.toggle("U_Active");
      button.classList.toggle("U_Inactive");
    }
  }

  submitForm(event) {
    event.preventDefault();
    const form = event.currentTarget.closest("form");
    if (form) {
      form.requestSubmit();
    }
  }

  // New method to track changes to cards for batch saving
  registerCardChange(event) {
    console.log("Card change detected:", event.detail);
    
    const cardId = event.detail.cardId;
    const changes = event.detail.changes;
    
    if (!cardId) {
      console.error("Card change event missing cardId:", event.detail);
      return;
    }
    
    // Store these changes to submit later
    if (!this.pendingCardChanges[cardId]) {
      this.pendingCardChanges[cardId] = {};
    }
    
    // Merge the new changes with any existing ones
    Object.assign(this.pendingCardChanges[cardId], changes);
    
    // Show the batch save button
    const batchSaveBtn = this.element.querySelector('.A_CardButton.U_BatchSave');
    if (batchSaveBtn) {
      batchSaveBtn.classList.add('U_HasChanges');
    }
    
    console.log("Updated pending changes:", this.pendingCardChanges);
  }
  
  // New method to batch save all cards in the section
  batchSaveSection(event) {
    event.preventDefault();
    
    // Get the section ID and the title from the section title form
    const sectionElement = this.element;
    const sectionId = this.sectionIdValue || sectionElement.dataset.sectionId;
    const titleInput = sectionElement.querySelector('.A_CardsSectionTitle');
    const sectionTitle = titleInput ? titleInput.value.trim() : null;
    
    // If we don't have any pending changes and no section title change, no need to save
    if (Object.keys(this.pendingCardChanges).length === 0 && !sectionTitle) {
      console.log("No changes to save");
      return;
    }
    
    console.log("Saving changes for section:", sectionId, "with cards:", this.pendingCardChanges);
    
    // Make sure the card IDs are strings (not numbers) to match Ruby hash keys
    // Also ensure only valid attributes are included
    const cardChanges = {};
    Object.keys(this.pendingCardChanges).forEach(cardId => {
      const stringCardId = String(cardId);
      const changes = this.pendingCardChanges[cardId];
      
      // Only include permitted attributes
      const cleanChanges = {};
      if (changes.title !== undefined) cleanChanges.title = changes.title;
      if (changes.content !== undefined) cleanChanges.content = changes.content;
      if (changes.url !== undefined) cleanChanges.url = changes.url;
      
      // Only add to changes if there's something to update
      if (Object.keys(cleanChanges).length > 0) {
        cardChanges[stringCardId] = cleanChanges;
      }
    });
    
    // Prepare the data for the batch update
    const sectionData = {};
    
    // Only include section data if title is present
    if (sectionTitle) {
      sectionData.section = { title: sectionTitle };
    }
    
    // Only include cards if there are changes
    if (Object.keys(cardChanges).length > 0) {
      sectionData.cards = cardChanges;
    }
    
    console.log("Sending batch update with data:", JSON.stringify(sectionData));
    
    // Get the CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    // Determine the URL for the batch update
    const path = window.location.pathname;
    const userIdMatch = path.match(/\/users\/(\d+)/);
    const userId = userIdMatch ? userIdMatch[1] : null;
    
    if (!userId || !sectionId) {
      console.error("Missing userId or sectionId for batch update");
      return;
    }
    
    const batchUpdateUrl = `/users/${userId}/sections/${sectionId}/batch_update`;
    
    // Show a loading state on the button
    const batchSaveBtn = this.element.querySelector('.A_CardButton.U_BatchSave');
    if (batchSaveBtn) {
      batchSaveBtn.classList.add('U_Loading');
    }
    
    // Send the batch update request
    fetch(batchUpdateUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html, application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(sectionData)
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(errorData => {
          console.error("Error response:", errorData);
          throw new Error(`Error ${response.status}: ${errorData.error || 'Unknown error'}`);
        }).catch(err => {
          // If we can't parse the error as JSON, just throw the status
          if (err.message && err.message.includes('JSON')) {
            throw new Error(`Error: ${response.status}`);
          }
          throw err;
        });
      }
      return response.text();
    })
    .then(html => {
      // Reset the pending changes after successful save
      this.pendingCardChanges = {};
      
      // Update the UI to show changes were saved
      if (batchSaveBtn) {
        batchSaveBtn.classList.remove('U_Loading');
        batchSaveBtn.classList.remove('U_HasChanges');
        
        // Show a temporary success indicator
        batchSaveBtn.classList.add('U_Success');
        setTimeout(() => {
          batchSaveBtn.classList.remove('U_Success');
        }, 2000);
      }
      
      // Update the original values in all the cards that were changed
      // Find all card controllers in this section
      this.updateOriginalCardValues();
      
      console.log("Batch save successful!");
    })
    .catch(error => {
      console.error("Error during batch save:", error);
      
      // Update UI to show error state
      if (batchSaveBtn) {
        batchSaveBtn.classList.remove('U_Loading');
        batchSaveBtn.classList.add('U_Error');
        
        // Show the error message in a tooltip
        const errorTooltip = document.createElement('div');
        errorTooltip.className = 'A_ErrorTooltip';
        errorTooltip.textContent = error.message || 'Failed to save changes';
        batchSaveBtn.appendChild(errorTooltip);
        
        // Remove error state after a delay
        setTimeout(() => {
          batchSaveBtn.classList.remove('U_Error');
          if (errorTooltip && errorTooltip.parentNode) {
            errorTooltip.parentNode.removeChild(errorTooltip);
          }
        }, 5000);
      }
    });
  }
  
  // Helper method to update the original values in all card controllers after a successful save
  updateOriginalCardValues() {
    // Find all text cards in this section
    const textCards = this.element.querySelectorAll('[data-controller="inline-text-card"]');
    textCards.forEach(card => {
      // Check if the card has the controller
      if (card.getAttribute('data-controller').includes('inline-text-card')) {
        // Get the controller from the Stimulus application
        try {
          const controller = this.application.getControllerForElementAndIdentifier(card, 'inline-text-card');
          if (controller && typeof controller.updateOriginals === 'function') {
            controller.updateOriginals();
          }
        } catch (e) {
          console.error('Error updating text card original values:', e);
        }
      }
    });
    
    // Find all divider cards in this section
    const dividerCards = this.element.querySelectorAll('[data-controller="inline-divider-card"]');
    dividerCards.forEach(card => {
      // Check if the card has the controller
      if (card.getAttribute('data-controller').includes('inline-divider-card')) {
        // Get the controller from the Stimulus application  
        try {
          const controller = this.application.getControllerForElementAndIdentifier(card, 'inline-divider-card');
          if (controller && typeof controller.updateOriginals === 'function') {
            controller.updateOriginals();
          }
        } catch (e) {
          console.error('Error updating divider card original values:', e);
        }
      }
    });
  }
}
