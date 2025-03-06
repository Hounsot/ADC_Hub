import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["actions", "settings"]

  connect() {
    // Hide the actions menu by default (if not already hidden by CSS)
    this.hideActions()
  }

  toggle(event) {
    event.preventDefault()
    
    console.log(this.settingsTarget)
    // Toggle the U_Active class on the settings button
    this.settingsTarget.classList.toggle("U_Active")
    
    // Toggle the U_Active class on the actions menu
    this.actionsTarget.classList.toggle("U_Active")
    
    // Stop propagation to prevent document click handler from firing immediately
    event.stopPropagation()
    
    // Add document click handler to hide when clicking outside
    if (this.settingsTarget.classList.contains("U_Active")) {
      this.addDocumentClickHandler()
    } else {
      this.removeDocumentClickHandler()
    }
  }

  hideActions() {
    this.settingsTarget.classList.remove("U_Active")
    this.actionsTarget.classList.remove("U_Active")
    this.removeDocumentClickHandler()
  }
  
  // Handler to hide menu when clicking outside
  handleDocumentClick = (event) => {
    if (!this.settingsTarget.contains(event.target) && !this.actionsTarget.contains(event.target)) {
      this.hideActions()
    }
  }
  
  addDocumentClickHandler() {
    document.addEventListener("click", this.handleDocumentClick)
  }
  
  removeDocumentClickHandler() {
    document.removeEventListener("click", this.handleDocumentClick)
  }
  
  disconnect() {
    // Clean up event listeners when controller is disconnected
    this.removeDocumentClickHandler()
  }
} 