import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["button", "countHeartEmoji", "countThumbsUpEmoji", "countMindBlownEmoji", "countStarStruckEmoji"]
  static values = { 
    activityId: Number,
    currentUserId: Number
  }
  
  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ReactionsChannel",
        activity_id: this.activityIdValue
      },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this)
      }
    )
  }
  
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
  
  toggleReaction(event) {
    const emoji = event.currentTarget.dataset.reactionEmojiParam
    
    fetch(`/activities/${this.activityIdValue}/reactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ emoji_type: emoji })
    })
    // We don't need to update the UI here as Action Cable will broadcast the changes
  }
  
  _connected() {
    console.log(`Connected to reactions for activity ${this.activityIdValue}`)
  }
  
  _disconnected() {
    console.log(`Disconnected from reactions for activity ${this.activityIdValue}`)
  }
  
  _received(data) {
    if (data.activity_id !== this.activityIdValue) return
    
    // Update reaction counts
    const counts = data.reaction_counts
    this.updateCounts(counts)
    
    // Update active state for current user
    if (data.current_user_reaction === this.currentUserIdValue) {
      this.updateActiveState(data.current_user_reaction_type)
    }
  }
  
  updateCounts(counts) {
    // Map emoji to their corresponding target names
    const emojiTargetMap = {
      "❤️": "countHeartEmoji",
      "👍": "countThumbsUpEmoji", 
      "🤯": "countMindBlownEmoji",
      "🤩": "countStarStruckEmoji"
    }
    
    Object.entries(counts).forEach(([emoji, count]) => {
      const targetName = emojiTargetMap[emoji]
      if (targetName && this.hasTarget(targetName)) {
        this[`${targetName}Target`].textContent = count
      }
    })
  }
  
  updateActiveState(activeEmojiType) {
    this.buttonTargets.forEach(button => {
      const buttonEmoji = button.dataset.reactionEmojiParam
      button.classList.toggle('active', buttonEmoji === activeEmojiType)
    })
  }
} 