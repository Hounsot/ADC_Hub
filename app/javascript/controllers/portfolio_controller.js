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
}
