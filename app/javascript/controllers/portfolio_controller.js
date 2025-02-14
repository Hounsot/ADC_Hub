import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["userCard", "addButton", "actionBar", "blur"]; // Add addButton target
    static values = {
    breakpoint: { type: Number, default: 600 },
    cardType: { type: String, default: "U_1/1" }, // Default card type
  };

  connect() {
    this.addButtonTarget.addEventListener("click", this.toggleActionBar.bind(this));
  }

  toggleActionBar() {
    this.blurTarget.classList.toggle('U_Active')
    this.actionBarTarget.classList.toggle("U_Active");
  }
}
