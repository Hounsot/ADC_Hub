import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="wrapped"
export default class extends Controller {
  static targets = ["results"]

  // Called when the user clicks the "Generate My Wrapped" button
  generateWrapped(event) {
    event.preventDefault()

    // We'll do a fetch request to /wrapped/generate.json
    fetch("/wrapped/generate.json", {
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      }
    })
      .then((response) => response.json())
      .then((data) => {
        // data = { insights: { ... } }
        this.displayInsights(data.insights)
      })
      .catch((error) => {
        console.error("Error fetching wrapped data:", error)
        this.element.querySelector("#wrapped-results").innerHTML =
          "<p class='text-danger'>Error fetching data. Please try again.</p>"
      })
  }

  // Dynamically display the returned insights
  displayInsights(insights) {
    /*
      insights is something like:
      {
        total_projects: 14,
        average_mark: 9.2,
        average_rating: 3.75,
        top_collaborators: { "Nikolay": 2, "Sofya": 1 },
        highest_mark_project: { ... },
        lowest_mark_project: { ... }
      }
    */

    const {
      total_projects,
      average_mark,
      average_rating,
      top_collaborators,
      highest_mark_project,
      lowest_mark_project
    } = insights

    // Format collaborator info
    const collaboratorsHtml = Object.entries(top_collaborators)
      .map(([name, count]) => `<li>${name}: ${count}</li>`)
      .join("")

    // Example: create a few cards for the data
    const resultsHTML = `
      <div class="card mb-3 p-3">
        <h3 style="color: white">Total Projects</h3>
        <p> style="color: white"${total_projects}</p>
      </div>

      <div class="card mb-3 p-3">
        <h3 style="color: white">Average Mark</h3>
        <p style="color: white">${average_mark}</p>
      </div>

      <div class="card mb-3 p-3">
        <h3 style="color: white">Average Rating</h3>
        <p style="color: white">${average_rating}</p>
      </div>

      <div class="card mb-3 p-3">
        <h3 style="color: white">Top Collaborators</h3>
        <ul style="color: white">${collaboratorsHtml}</ul>
      </div>

      <div class="card mb-3 p-3">
        <h3 style="color: white">Highest Mark Project</h3>
        ${
          highest_mark_project
            ? `<p style="color: white">${highest_mark_project.title} (${highest_mark_project.totalMark || "N/A"})</p>`
            : `<p style="color: white">N/A</p>`
        }
      </div>

      <div class="card mb-3 p-3">
        <h3 style="color: white">Lowest Mark Project</h3>
        ${
          lowest_mark_project
            ? `<p style="color: white">${lowest_mark_project.title} (${lowest_mark_project.totalMark || "N/A"})</p>`
            : `<p style="color: white">N/A</p>`
        }
      </div>
    `

    this.element.querySelector("#wrapped-results").innerHTML = resultsHTML
  }
}
