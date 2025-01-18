document.addEventListener('DOMContentLoaded', function() {
    const createButton = document.getElementById('CreateButton');
    const createButtonWrapper = document.querySelector('.W_CreateButton');
    const pageBlur = document.querySelector('.A_Blur');
    const pageBody = document.querySelector('body')
    function toggleActive() {
      createButtonWrapper.classList.toggle('U_Active');
      pageBlur.classList.toggle('U_Active');
      pageBody.classList.toggle('U_NoScroll')
    }
  
    // Toggle classes when the CreateButton is clicked
    if (createButton) {
      createButton.addEventListener('click', toggleActive);
    }
  
    // Also toggle classes when the A_Blur element is clicked
    if (pageBlur) {
      pageBlur.addEventListener('click', toggleActive);
    }
  });
  