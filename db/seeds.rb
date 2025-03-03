# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
#
# Run with: rails db:seed
#
# Note: If you want to completely reset your development database before
# seeding, you can do:
#   rails db:drop db:create db:migrate db:seed

# 1. Define arrays of data that we'll sample from:

TECH_COMPANIES = [
  "Apple",
  "Microsoft",
  "Google",
  "Amazon",
  "VMware",
  "Samsung",
  "Tencent",
  "TSMC",
  "NVIDIA",
  "PayPal",
  "Broadcom",
  "HPE"
]

POSITIONS = [
  "Frontend Developer",
  "Backend Developer",
  "Full Stack Engineer",
  "Data Scientist",
  "Product Manager",
  "UI/UX Designer",
  "DevOps Engineer",
  "Solutions Architect",
  "Technical Writer",
  "QA Engineer",
  "Project Manager",
  "Site Reliability Engineer (SRE)",
  "Mobile Developer",
  "Machine Learning Engineer"
]

LOCATIONS = [
  "San Francisco, CA",
  "New York, NY",
  "Austin, TX",
  "Toronto, Canada",
  "London, UK",
  "Berlin, Germany",
  "Tokyo, Japan",
  "Sydney, Australia",
  "Remote",
  "Paris, France"
]

SALARIES = [
  "$60,000 - $70,000",
  "$70,000 - $80,000",
  "$80,000 - $90,000",
  "$90,000 - $100,000",
  "$100,000 - $120,000",
  "$120,000 - $140,000",
  "$140,000 - $160,000"
]

DESCRIPTIONS = [
  "We're looking for someone who is passionate about technology and ready to push boundaries.",
  "As part of our team, you'll be working on cutting-edge solutions for modern businesses.",
  "Join us and help shape the future of our industry with creativity and innovation.",
  "In this role, you will collaborate with cross-functional teams to deliver high-quality results.",
  "We value work-life balance and offer a flexible environment for our employees."
]
RANDOM_LINKS = [
  # YouTube links
  "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "https://www.youtube.com/watch?v=9bZkp7q19f0",
  "https://www.youtube.com/watch?v=JGwWNGJdvx8",
  "https://www.youtube.com/watch?v=kJQP7kiw5Fk",

  # Behance links
  "https://www.behance.net/gallery/96851215/Digital-Art-Collection",
  "https://www.behance.net/gallery/87349339/UI-Design-Portfolio",
  "https://www.behance.net/gallery/72635295/Brand-Identity-Project",

  # Spotify links
  "https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT",
  "https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3",
  "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M",

  # VK links
  "https://vk.com/feed",
  "https://vk.com/music",
  "https://vk.com/video",

  # Rutube links
  "https://rutube.ru/video/person/1037293/",
  "https://rutube.ru/video/private/79053c3c5c3dac1eed3703ed65da3ce0/",
  "https://rutube.ru/video/c0596a7b8b5f6f3a77c9f3e56e87ce67/",

  # X (Twitter) links
  "https://twitter.com/elonmusk",
  "https://twitter.com/NASA",
  "https://twitter.com/NatGeo",

  # Yandex Music links
  "https://music.yandex.ru/album/5307396",
  "https://music.yandex.ru/artist/41126",
  "https://music.yandex.ru/users/music-blog/playlists/1000",

  # Wikipedia links
  "https://en.wikipedia.org/wiki/Web_development",
  "https://en.wikipedia.org/wiki/Artificial_intelligence",
  "https://en.wikipedia.org/wiki/Data_science",

  # Vimeo links
  "https://vimeo.com/22439234",
  "https://vimeo.com/channels/staffpicks/713347905",
  "https://vimeo.com/groups/motion/videos/73686146",

  # Dprofile links
  "https://dprofile.ru/user/1234567890",
  "https://dprofile.ru/user/9876543210",
  "https://dprofile.ru/user/1122334455",
  "https://dprofile.ru/user/6677889900",
  "https://dprofile.ru/user/5566778899",
  "https://dprofile.ru/user/4455667788"
]

USERNAMES = [
  "Даниил Парамонов",
  "Александр Иванов",
  "Иван Петров",
  "Максим Сидоров",
  "Кирилл Кузнецов",
  "Михаил Морозов",
  "Никита Федоров",
  "Артем Попов",
  "Дмитрий Соколов",
  "Сергей Козлов",
  "Алексей Орлов",
  "Михаил Кузнецов",
  "Александр Петров",
  "Александр Кузнецов",
  "Александр Петров",
  "Александр Кузнецов",
  "Александр Петров",
  "Александр Кузнецов"
]

EMAILS = [
  "danil@example.com",
  "alex@example.com",
  "ivan@example.com",
  "maxim@example.com",
  "kirill@example.com",
  "mikhail@example.com",
  "nikita@example.com",
  "artem@example.com",
  "dmitriy@example.com",
  "sergey@example.com",
  "alexander@example.com",
  "harry@example.com",
  "ian@example.com",
  "jack@example.com",
  "kyle@example.com",
  "larry@example.com",
  "mike@example.com",
  "nick@example.com"
]
CARD_TYPES = [ "text", "link", "image" ]

SECTION_TITLES = [
  "My Work",
  "Projects",
  "Education",
  "Skills",
  "Achievements"
]

# 2. (Optional) Clear existing data to avoid duplicates:
#    Uncomment these lines if you want a fresh start each time you run seeds:
#
Vacancy.destroy_all
Card.destroy_all
User.destroy_all
Company.destroy_all
Section.destroy_all

# Helper methods
def random_avatar
  avatars_path = Rails.root.join('db', 'seeds', 'avatars')
  avatars = Dir[File.join(avatars_path, '*')].select { |f| File.file?(f) }
  File.open(avatars.sample)
end

def random_image
  # Look in various image directories and get a random image
  base_path = Rails.root.join('db', 'seeds', 'images')

  # Get all image files from all subdirectories
  image_files = []
  Dir.glob(File.join(base_path, '**', '*')).each do |file|
    if File.file?(file) && file.match?(/\.(jpg|jpeg|png|gif)$/i)
      image_files << file
    end
  end

  # Return a File object for a random image
  File.open(image_files.sample)
end

def generate_card_title(card_type)
  case card_type
  when "text"
    "Sample Text Card"
  when "link"
    "Check this link out!"
  when "image"
    "My cool image"
  when "job"
    "Job Overview"
  else
    "Generic Card"
  end
end

def generate_card_content(card_type)
  case card_type
  when "text"
    "Some interesting text content goes here."
  when "job"
    "My current job details..."
  when "image"
    "Just an example image card"
  when "link"
    "A short description of the link"
  else
    "No specific content"
  end
end

# Create a section for a user and populate it with image cards
def create_image_section(user, folder_path, section_name)
  # Don't create more than 6 sections per user
  if user.sections.count >= 6
    puts "Skipping section creation for #{user.name} - already has 6 sections"
    return
  end

  # Create a new section for this set of images
  section = user.sections.create!(
    title: section_name.titleize,
    position: user.sections.count + 1  # Place it after existing sections
  )

  # Find all image files in the specified folder
  images = Dir[File.join(folder_path, '*')].select { |f|
    File.file?(f) && f.match?(/\.(jpg|jpeg|png|gif)$/i)
  }

  # Create a card for each image in the folder
  images.each_with_index do |image_path, index|
    # Check the previous card's size to prevent consecutive medium cards
    previous_card = section.cards.find_by(position: index)

    # If previous card was medium, make this one square, otherwise randomly choose
    size = if previous_card&.size == "medium"
      "square"
    else
      [ "square", "medium" ].sample
    end

    # Create the card with the determined size
    card = section.cards.create!(
      card_type: "image",
      position: index + 1,
      size: size
    )

    # Attach the actual image file to the card using Active Storage
    card.image.attach(
      io: File.open(image_path),
      filename: File.basename(image_path),
      content_type: "image/#{File.extname(image_path).delete('.')}"
    )
  end
end

# 3. STEP 1: Create prerequisites (Users & Companies)
puts "Creating Users..."

users = []
USERNAMES.each_with_index do |username, i|
  user = User.create!(
    email: EMAILS[i],
    name: username,
    password: "password",
    position: POSITIONS.sample
  )

  # Attach a random avatar
  user.avatar.attach(
    io: random_avatar,
    filename: "avatar_#{username}.jpg",
    content_type: 'image/jpeg'
  )

  users << user
end

puts "Created #{users.count} Users with avatars."

puts "Creating Companies..."

companies = []
TECH_COMPANIES.each do |company_name|
  company = Company.create!(
    name: company_name,
    description: "#{company_name} is an industry leader in advanced tech solutions.",
    link: "https://www.#{company_name.downcase.gsub(/\s+/, '')}.com"
  )
  companies << company
end

puts "Created #{companies.count} Companies."

puts "Assigning each user to a random company..."

users.each do |user|
  user.update!(company: companies.sample)
end

puts "Done assigning companies to users!"

# 4. STEP 2: Prepare image section data
base_path = Rails.root.join('db', 'seeds', 'images')

subcategory_paths = []
Dir[File.join(base_path, '*')].each do |category_path|
  next unless File.directory?(category_path)
  Dir[File.join(category_path, '*')].each do |subcategory_path|
    next unless File.directory?(subcategory_path)
    subcategory_paths << subcategory_path
  end
end

subcategory_paths.shuffle!

# 5. STEP 3: Create a list of mixed actions to be performed in random order
puts "Preparing randomized creation actions..."

# Each action will be a Proc that creates something
actions = []

# Add vacancy creation actions
companies.each do |company|
  # Each company will have 3-7 vacancies
  rand(1..2).times do
    actions << -> {
      Vacancy.create!(
        title: POSITIONS.sample,
        description: DESCRIPTIONS.sample,
        salary: SALARIES.sample,
        location: LOCATIONS.sample,
        employment_type: [ "Фулл-тайм", "Парт-тайм", "Стажировка" ].sample,
        company: company,
        user: users.sample  # pick any user at random
      )
      # Sleep a short time to ensure different timestamps
      sleep(0.1)
    }
  end
end

# Add regular section creation actions
users.each do |user|
  # Create 1-2 regular sections for each user
  num_sections = rand(1..2)

  num_sections.times do |section_index|
    actions << -> {
      section = user.sections.create!(
        title: SECTION_TITLES[section_index] || "Custom Section #{section_index + 1}",
        position: user.sections.count + 1
      )

      # Create 3-5 cards for this section
      num_cards = rand(3..5)

      num_cards.times do |card_index|
        card_type = CARD_TYPES.sample

        # Check the previous card's size to prevent consecutive medium cards
        previous_card = section.cards.find_by(position: card_index)

        # If previous card was medium, make this one square, otherwise randomly choose
        size = if previous_card&.size == "medium"
          "square"
        else
          [ "square", "medium" ].sample
        end

        card = section.cards.create!(
          card_type: card_type,
          title: generate_card_title(card_type),
          content: generate_card_content(card_type),
          url: (card_type == "link" ? RANDOM_LINKS.sample : nil),
          position: card_index + 1,  # simple ascending positions
          size: size  # Use the determined size instead of random selection
        )

        # If this is an image card, attach a random image
        if card_type == "image"
          begin
            random_img = random_image
            card.image.attach(
              io: random_img,
              filename: File.basename(random_img.path),
              content_type: "image/#{File.extname(random_img.path).delete('.')}"
            )
          rescue => e
            puts "Error attaching image to card: #{e.message}"
          end
        end
      end
      # Sleep a short time to ensure different timestamps
      sleep(0.1)
    }
  end
end

# Add image section creation actions
subcategory_paths.each do |subcategory_path|
  subcategory_name = File.basename(subcategory_path)

  actions << -> {
    # Find users who don't yet have 6 sections
    eligible_users = User.all.select { |user| user.sections.count < 4 }

    # Skip if all users have reached their section limit
    if eligible_users.present?
      # Pick a random eligible user for this section
      user = eligible_users.sample

      # Create the section with its images
      create_image_section(user, subcategory_path, subcategory_name)

      # Sleep a short time to ensure different timestamps
      sleep(0.1)
    end
  }
end

# 6. STEP 4: Shuffle the actions to randomize creation order
actions.shuffle!

# 7. STEP 5: Execute the actions in random order
puts "Creating mixed content (vacancies, sections, cards)..."
actions.each_with_index do |action, index|
  action.call
  puts "Completed action #{index + 1}/#{actions.count}" if (index + 1) % 10 == 0
end

puts "Seed data created successfully!"
puts "Created #{Vacancy.count} Vacancies, #{Section.count} Sections with #{Card.count} Cards"
