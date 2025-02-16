import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]
  static values = {
    url: String
  }
  toggleDropdown(event) {
    console.log("toggleDropdown called"); // Add a debug log
    event.preventDefault()
    const dropdown = this.dropdownTarget
    dropdown.style.display = (dropdown.style.display === "none") ? "block" : "none"
  }

  create(event) {
    event.preventDefault()
    const cardType = event.currentTarget.dataset.cardsTypeValue
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    // We'll POST to e.g. /users/1/cards.json with { card: { card_type: "text" } }
    fetch(this.urlValue + ".json", {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ card: { card_type: cardType } })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error("Network response was not ok")
      }
      return response.json()
    })
    .then(data => {
      // data.html contains the rendered partial
      this.appendCard(data.html)
    })
    .catch(error => {
      console.error("Error creating card:", error)
    })
  }

  appendCard(html) {
    const cardsContainer = document.querySelector(".M_UserCards")
    cardsContainer.insertAdjacentHTML("beforeend", html)
  }
  }
