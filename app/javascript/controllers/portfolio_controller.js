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
    const cardId = event.detail.cardId;
    const changes = event.detail.changes;
    
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
  }
  
  // New method to batch save all cards in the section
  batchSaveSection(event) {
    event.preventDefault();
    
    // Get the section ID and the title from the section title form
    const sectionElement = this.element;
    const sectionId = this.sectionIdValue || sectionElement.dataset.sectionId;
    const titleInput = sectionElement.querySelector('.A_CardsSectionTitle');
    const sectionTitle = titleInput ? titleInput.value : null;
    
    // If we don't have any pending changes and no section title change, no need to save
    if (Object.keys(this.pendingCardChanges).length === 0 && !sectionTitle) {
      console.log("No changes to save");
      return;
    }
    
    // Prepare the data for the batch update
    const sectionData = {
      section: { title: sectionTitle },
      cards: this.pendingCardChanges
    };
    
    // Get the CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    // Determine the URL for the batch update
    const userId = window.location.pathname.split('/')[2]; // Assumes URL pattern /users/:id
    const batchUpdateUrl = `/users/${userId}/sections/${sectionId}/batch_update`;
    
    // Send the batch update request
    fetch(batchUpdateUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(sectionData)
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`Error: ${response.status}`);
      }
      return response.text();
    })
    .then(html => {
      // Reset the pending changes after successful save
      this.pendingCardChanges = {};
      
      // Update the UI to show changes were saved
      const batchSaveBtn = this.element.querySelector('.A_CardButton.U_BatchSave');
      if (batchSaveBtn) {
        batchSaveBtn.classList.remove('U_HasChanges');
        
        // Show a temporary success indicator
        batchSaveBtn.classList.add('U_Success');
        setTimeout(() => {
          batchSaveBtn.classList.remove('U_Success');
        }, 2000);
      }
      
      // If there was a turbo stream response, Turbo will handle it
      // Otherwise, we can manually update elements if needed
    })
    .catch(error => {
      console.error("Error saving section:", error);
      // Handle error (show error message)
    });
  }
}
