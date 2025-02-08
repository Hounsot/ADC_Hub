import { Controller } from "@hotwired/stimulus"

// This controller cycles through images in each "A_LandingCompany"
// and toggles the U_Inactive class to indicate which img is active.
export default class extends Controller {
  static targets = ["company", "swipe", 'swipeContainer', 'swipeArrowLeft', 'swipeArrowRight']
  
  connect() {
    console.log('All', this)
    console.log('Swipe Arrow Left', this.swipeArrowLeftTarget)
    console.log('Swipe Arrow Right', this.swipeArrowRightTarget)
    this.currentSlideIndex = 0
    this.totalSlides = this.swipeTargets.length  
    this.swipeArrowLeftTarget.addEventListener("click", () => this.goToPreviousSlide())
    this.swipeArrowRightTarget.addEventListener("click", () => this.goToNextSlide())
    this.updateSliderPosition();
    this.swipeTargets.forEach(swipeCard => {
      let plusIcon = swipeCard.querySelector('.Q_ButtonIcon');
      if (plusIcon) {
        swipeCard.addEventListener('mouseenter', () => {
          plusIcon.classList.add('U_Active');
        });
      
        swipeCard.addEventListener('mouseleave', () => {
          plusIcon.classList.remove('U_Active');
        });
      } else {
        console.warn('Plus icon was not found in card:', card);
      }
    });
    // currentIndexes will track the active image index for each A_LandingCompany
    this.currentIndexes = this.companyTargets.map(() => 0)
    // Start the rotation sequence
    this.scheduleNextCompany(0, /* initialDelay = */ 0)
  }

  // Updates one A_LandingCompany at index `i`
  updateCompany(i) {
    const companyEl = this.companyTargets[i]
    const images = companyEl.querySelectorAll("img.Q_LandingImage")
    let currentIndex = this.currentIndexes[i]
    // console.log("Updating company:", i, "images length:", images.length)

    // Deactivate all images
    images.forEach(img => img.classList.add("U_Inactive"))
    // Activate the current image
    images[currentIndex].classList.remove("U_Inactive")

    // Move to the next index (loop back to 0 at the end)
    currentIndex = (currentIndex + 1) % images.length
    this.currentIndexes[i] = currentIndex
  }  

  calculateSwipeWidth() {
    let swipeEl = this.swipeTargets[0];
    let swipeWidth = swipeEl.getBoundingClientRect().width;
    let swipeComputedStyles = window.getComputedStyle(this.swipeContainerTarget);
    let gapValue = swipeComputedStyles.getPropertyValue('gap') || "0px";
    let gap = parseFloat(gapValue) || 0;
    return swipeWidth + gap;
  }
  
  updateSliderPosition() {
    const slideWidth = this.calculateSwipeWidth();
    const translateX = -(this.currentSlideIndex * slideWidth);
    this.swipeContainerTarget.style.transform = `translateX(${translateX}px)`;
  }

  goToPreviousSlide() {
    console.log('Previous')
    console.log(this.currentSlideIndex)
    console.log(this.totalSlides)
    if (this.currentSlideIndex > 0) {
      this.currentSlideIndex--;
      this.updateSliderPosition();
    }
  }

  goToNextSlide() {
    console.log('Next')
    console.log(this.currentSlideIndex)
    console.log(this.totalSlides)
    if (this.currentSlideIndex < this.totalSlides - 1) {
      this.currentSlideIndex++;
      this.updateSliderPosition();
    }
  }

  // Schedules an update for the company at index `i`,
  // then schedules the next one after 0.5s,
  // and after the last company, waits 4s and repeats.
  scheduleNextCompany(i, delay) {
    this.timeoutId = setTimeout(() => {
      this.updateCompany(i)

      // If we haven't reached the last company, schedule the next
      if (i < this.companyTargets.length - 1) {
        this.scheduleNextCompany(i + 1, 100) // 0.5s between each company update
      } else {
        // We've updated all companies in this cycle
        // Wait 4s, then start again at the first company
        this.scheduleNextCompany(0, 3000)
      }
    }, delay)
  }
}
