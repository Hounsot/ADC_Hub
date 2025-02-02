import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="devise-form"
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", () => {
      this.element.classList.toggle('U_Active')
      console.log("Element was clicked!", event);
    });
  }
}
