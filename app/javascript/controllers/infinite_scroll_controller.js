import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = { page: Number, loading: Boolean }

  connect() {
    this.pageValue = this.pageValue || 1
    this.loadingValue = false
    this.scrollTimeout = null
    this.boundScrollHandler = this.handleScrollDebounced.bind(this)
    window.addEventListener('scroll', this.boundScrollHandler)
  }

  disconnect() {
    window.removeEventListener('scroll', this.boundScrollHandler)
    if (this.scrollTimeout) {
      clearTimeout(this.scrollTimeout)
    }
  }
  
  handleScrollDebounced() {
    if (this.scrollTimeout) {
      clearTimeout(this.scrollTimeout)
    }
    
    this.scrollTimeout = setTimeout(() => {
      this.handleScroll()
    }, 200)
  }
  
  handleScroll() {
    if (this.loadingValue || !this.hasPaginationTarget) return
    
    const paginationRect = this.paginationTarget.getBoundingClientRect()
    const windowHeight = window.innerHeight
    
    const isNearBottom = paginationRect.top < windowHeight + 100;
    
    if (isNearBottom) {
      this.loadMore()
    }
  }
  
  loadMore() {
    this.loadingValue = true
    this.paginationTarget.classList.add('loading')
    
    fetch(`/activities?page=${this.pageValue + 1}`, {
      headers: {
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => {
      if (!response.ok) throw new Error("Network response was not ok")
      return response.text()
    })
    .then(html => {
      if (html.trim()) {
        this.entriesTarget.insertAdjacentHTML('beforeend', html)
        this.pageValue++
        
        const newItems = html.match(/<div class="M_FeedItem/g) || []
        if (newItems.length < 20) {
          // Reached the end, remove scroll listener
          window.removeEventListener('scroll', this.boundScrollHandler)
        }
      } else {
        // No more content
        window.removeEventListener('scroll', this.boundScrollHandler)
      }
    })
    .catch(error => {
      console.error("Error loading more activities:", error)
    })
    .finally(() => {
      this.loadingValue = false
      this.paginationTarget.classList.remove('loading')
    })
  }
}