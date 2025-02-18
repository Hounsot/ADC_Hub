import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["title"]
    static values = {
        url: String
      }    
    save(event) {
        event.preventDefault()
        const newTitle = this.titleTarget.textContent.trim()
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content
        fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({
                card: {
                    title: newTitle
                }
            })
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Network error: ${response.status} ${response.statusText}`)
                }
                return response.json()
            })
            .then(data => {
                console.log("Card updated successfully:", data)
            })
            .catch(error => {
                console.error("Error updating card:", error)
            })
    }
} 