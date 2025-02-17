import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "imageFileInput"]
  static values = {
    url: String
  }
  toggleDropdown(event) {
    console.log("toggleDropdown called"); // Add a debug log
    event.preventDefault()
    const dropdown = this.dropdownTarget
    dropdown.style.display = (dropdown.style.display === "none") ? "block" : "none"
  }
  connect() {
    // When the user actually picks a file, call `uploadImage`
    this.imageFileInputTarget.addEventListener("change", this.uploadImage.bind(this))
  }
  pickImage(event) {
    event.preventDefault()
    this.imageFileInputTarget.click()
  }
  uploadImage(event) {
    const file = event.target.files[0]
    if (!file) return // user canceled choosing a file

    // Prepare a multipart/form-data request with the chosen file
    const formData = new FormData()
    formData.append("card[card_type]", "image") // so the controller uses _image_card partial
    formData.append("card[image]", file)        // attach the file

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(`${this.urlValue}.json`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken
        // NOTE: Don't set "Content-Type" yourself; let fetch + FormData handle it
      },
      body: formData
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Server error: ${response.status} ${response.statusText}`)
        }
        return response.json()
      })
      .then(data => {
        // data.html is the partial from CardsController#create
        this.appendCard(data.html)

        // Optional: reset the file input if you want
        this.imageFileInputTarget.value = null
      })
      .catch(error => {
        console.error("Error creating image card:", error)
      })
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
    cardsContainer.insertAdjacentHTML("afterbegin", html)
  }
  }
