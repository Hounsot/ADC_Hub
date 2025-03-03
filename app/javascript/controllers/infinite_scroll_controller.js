import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = { page: Number, loading: Boolean }

  connect() {
    this.pageValue = this.pageValue || 1
    this.loadingValue = false
    this.intersectionObserver = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting && !this.loadingValue) {
        this.loadMore()
      }
    })
    
    if (this.hasPaginationTarget) {
      this.intersectionObserver.observe(this.paginationTarget)
    }
  }

  disconnect() {
    this.intersectionObserver.disconnect()
  }
  
  loadMore() {
    this.loadingValue = true
    const nextPage = this.pageValue + 1
    
    fetch(`/activities?page=${nextPage}`, {
      headers: {
        Accept: "text/html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.text())
    .then(html => {
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, "text/html")
      const newActivities = doc.querySelector(".O_FeedItems").innerHTML
      
      // Append new content
      this.entriesTarget.insertAdjacentHTML("beforeend", newActivities)
      
      // Update page number
      this.pageValue = nextPage
      
      // Check if there are more pages
      const hasPagination = doc.querySelector(".pagination .next")
      if (!hasPagination) {
        // No more results, disconnect observer
        this.intersectionObserver.disconnect()
      }
      
      this.loadingValue = false
    })
  }
} 