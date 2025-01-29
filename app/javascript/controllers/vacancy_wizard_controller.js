// app/javascript/controllers/vacancy_wizard_controller.js
import { Controller } from "@hotwired/stimulus"
import "canvas-confetti"
export default class extends Controller {
    static targets = [
    "step", "navButton",
    "previewCard", "previewTitle", "previewDescription",
    "previewLocation", "previewSalary", "previewEmploymentType", "previewWorkplaceType"
  ]

  connect() {
    this.currentStepIndex = 1
    this.showStep(this.currentStepIndex)
    this.updatePreview()
    this.updateNavActive(this.currentStepIndex)
  }

  // Move to next step
  goToNextStep() {
    if (this.currentStepIndex < this.stepTargets.length) {
      this.currentStepIndex++
      this.showStep(this.currentStepIndex)
      this.updateNavActive(this.currentStepIndex)
    }
  }

  // Move to previous step
  // goToPreviousStep() {
  //   if (this.currentStepIndex > 1) {
  //     this.currentStepIndex--
  //     this.showStep(this.currentStepIndex)
  //   }
  // }

  goToStep(event) {
    // 1) Read the "step" value from the HTML element that triggered the event.
    //    It’s stored in data-step, like <button data-step="3">.
    //    Because that value is a string (e.g., "3"), we use parseInt to convert it to a number (integer).
    const targetStepIndex = parseInt(event.currentTarget.dataset.step, 10)
    // 2) Check that the target step is at least 1 and at most the total number of steps.
    //    For instance, if you have 3 steps in your wizard, you only want to allow 1, 2, or 3.
    if (targetStepIndex >= 1 && targetStepIndex <= this.stepTargets.length) {
      
      // 3) Update the controller's currentStepIndex to the new value.
      this.currentStepIndex = targetStepIndex
  
      // 4) Call showStep(...) to hide all steps except the one you want to show now.
      this.showStep(this.currentStepIndex)
      this.updateNavActive(this.currentStepIndex)
    }
  }
    // Show/hide steps based on current step index
  showStep(stepIndex) {
    this.stepTargets.forEach((stepTarget) => {
      const targetIndex = parseInt(stepTarget.dataset.stepIndex, 10)
      stepTarget.classList.toggle("hidden", targetIndex !== stepIndex)
      if (this.currentStepIndex == this.stepTargets.length) {
        confetti({
          angle: 45,
          particleCount: 40,
          spread: 90,
          origin: { x: 0, y: 1 },
          decay: 0.945
        })    
      }
    })
  }
  updateNavActive(stepIndex) {
    let navButtonTargets = document.querySelectorAll('.A_FormSteps')
    console.log(navButtonTargets)
    navButtonTargets.forEach((button) => {
      const buttonStep = parseInt(button.dataset.step, 10)
      if (buttonStep === stepIndex) {
        button.classList.add("U_Active")
      } else {
        button.classList.remove("U_Active")
      }
    })
  }  
  // Update preview fields
  updatePreview(event) {
    // We can read from the event target or from this.element.querySelector, etc.

    // Example: if your form fields have 'name="vacancy[title]"'
    // you can read them directly:

    const titleField = this.element.querySelector('input[name="vacancy[title]"]')
    const locationField = this.element.querySelector('input[name="vacancy[location]"]')
    const salaryField = this.element.querySelector('input[name="vacancy[salary]"]')
    const employmentField = this.element.querySelector('input[name="vacancy[employment_type]"]:checked') || "Not selected"
    const workplaceField = this.element.querySelector('input[name="vacancy[workplace_type]"]:checked') || "Not selected"

    // Update preview targets
    this.previewTitleTarget.textContent = titleField.value || "Название вакансии"
    this.previewLocationTarget.textContent = `${locationField.value != "" ? `${locationField.value},` : "Локация,"}`
    this.previewSalaryTarget.textContent = salaryField.value || "Зарплата"
    
    // For employment type, we might add a class or do something special:
    const employmentType = employmentField.value
    this.previewEmploymentTypeTarget.textContent = employmentType || "Тип занятости"
    
    // workplace type
    const workplaceType = workplaceField.value
    this.previewWorkplaceTypeTarget.textContent = workplaceType || "формат работы"
    // Optionally, add logic to update classes (like "U_Full-time")
    // or reset them. For now, let's keep it simple.
        // 2) Toggle .U_Active on the selected radio button's parent
    // Remove .U_Active from all radio containers first:
    const allRadioButtonsEmploymentType = this.element.querySelectorAll('input[name="vacancy[employment_type]"]')
    allRadioButtonsEmploymentType.forEach((radio) => {
      radio.closest('.A_RadioButton')?.classList.remove('U_Active')
    })
    const allRadioButtonsWorkplaceType = this.element.querySelectorAll('input[name="vacancy[workplace_type]"]')
    allRadioButtonsWorkplaceType.forEach((radio) => {
      radio.closest('.A_RadioButton')?.classList.remove('U_Active')
    })
    switch (employmentType) {
      case "Фулл-тайм":
        this.previewEmploymentTypeTarget.classList.remove('U_Intertship')
        this.previewEmploymentTypeTarget.classList.remove('U_Part-time')
        this.previewEmploymentTypeTarget.classList.add('U_Full-time')
        break;
        case "Парт-тайм":
          this.previewEmploymentTypeTarget.classList.remove('U_Full-time')
          this.previewEmploymentTypeTarget.classList.remove('U_Intertship')
          this.previewEmploymentTypeTarget.classList.add('U_Part-time')
        break;
      case "Стажировка":
        this.previewEmploymentTypeTarget.classList.remove('U_Full-time')
        this.previewEmploymentTypeTarget.classList.remove('U_Part-time')
        this.previewEmploymentTypeTarget.classList.add('U_Intertship')
        break;
    }
    if (typeof employmentType !== 'undefined') {
      employmentField.closest('.A_RadioButton')?.classList.add('U_Active')
    }
    if (typeof workplaceType !== 'undefined') {
      workplaceField.closest('.A_RadioButton')?.classList.add('U_Active')
    }
  }
}
