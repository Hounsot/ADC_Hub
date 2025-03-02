import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "imageFileInput", "linkForm"]
  static values = {
    url: String,
    type: String
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

    // Get the section element
    const section = this.element.closest('[data-section-id]')

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
        this.appendCard(data.html, section)

        // Optional: reset the file input if you want
        this.imageFileInputTarget.value = null
      })
      .catch(error => {
        console.error("Error creating image card:", error)
      })
  }
  create(event) {
    event.preventDefault()
    const section = this.element.closest('[data-section-id]')
    const cardType = event.currentTarget.dataset.cardsTypeValue

    if (cardType === 'link') {
      this.showLinkForm(section)
      return
    }

    console.log(`sectionId: ${section}`)

    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',  // Change back to JSON
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        card: {
          card_type: cardType
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.html) {
        this.appendCard(data.html, section)
      }
    })
    .catch(error => console.error('Error:', error))
  }

  appendCard(html, section) {
    // Find the add card div
    const addCardDiv = section.querySelector('.W_AddCard')
    
    // Insert the new card before the add card div
    if (addCardDiv) {
      addCardDiv.insertAdjacentHTML('beforebegin', html)
    } else {
      // Fallback to appending at the end if W_AddCard is not found
      section.insertAdjacentHTML('beforeend', html)
    }
  }

  showLinkForm(section) {
    fetch(this.urlValue, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      const addCardDiv = section.querySelector('.W_AddCard')
      if (addCardDiv) {
        addCardDiv.insertAdjacentHTML('beforebegin', html)
      }
    })
  }

  cancelLinkForm(event) {
    event.preventDefault()
    const form = event.target.closest('turbo-frame')
    if (form) {
      form.remove()
    }
  }
}
