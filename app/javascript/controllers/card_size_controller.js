import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "input"]

  setSquare() {
    this.containerTarget.classList.remove("U_Medium")
    this.containerTarget.classList.add("U_Square")
    this.inputTarget.value = "square"
  }

  setMedium() {
    this.containerTarget.classList.remove("U_Square")
    this.containerTarget.classList.add("U_Medium")
    this.inputTarget.value = "medium"
  }
}