import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    position: Number,
    url: String
  }

  create(event) {
    event.preventDefault()
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        section: {
          title: "Новая секция",
          position: this.positionValue
        }
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const contentType = response.headers.get("Content-Type");
      if (contentType && contentType.includes("text/vnd.turbo-stream.html")) {
        return response.text();
      } else {
        return response.json();
      }
    })
    .then(data => {
      if (typeof data === 'string' && data.includes("<turbo-stream")) {
        Turbo.renderStreamMessage(data);
      } else if (data.success) {
        window.location.reload();
      }
    })
    .catch(error => {
      console.error("Error:", error);
    });
  }
} 