import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    event.preventDefault()
    
    // Find the form element
    const form = this.element
    
    // Submit the form
    form.requestSubmit()
  }
} 