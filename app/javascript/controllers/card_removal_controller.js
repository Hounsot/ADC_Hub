import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "destroyInput"]

  markForDestroy() {
    // Set the _destroy field to 1
    this.destroyInputTarget.value = "1"
    
    // Hide the card from view
    this.containerTarget.style.display = "none"
    
    // Optionally, you can add a "deleted" class for styling
    this.containerTarget.classList.add("deleted")
  }
}