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
  "IBM",
  "Intel",
  "Cisco",
  "Oracle",
  "SAP",
  "Dell Technologies",
  "Salesforce",
  "Adobe",
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


# 2. (Optional) Clear existing data to avoid duplicates:
#    Uncomment these lines if you want a fresh start each time you run seeds:
#
Vacancy.destroy_all
Card.destroy_all
User.destroy_all
Company.destroy_all
Section.destroy_all

# 3. Create a few Users (if you don't already have them):
puts "Creating Users..."

# We assume Devise or similar is used, requiring an email and password.
# We'll just create 5 example users.

# Helper method to get random avatar
def random_avatar
  avatars_path = Rails.root.join('db', 'seeds', 'avatars')
  avatars = Dir[File.join(avatars_path, '*')].select { |f| File.file?(f) }
  File.open(avatars.sample)
end

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
end

users = User.all
puts "Created #{users.count} Users with avatars."

# 4. Create Companies from the TECH_COMPANIES array:
puts "Creating Companies..."

TECH_COMPANIES.each do |company_name|
  Company.create!(
    name: company_name,
    description: "#{company_name} is an industry leader in advanced tech solutions.",
    link: "https://www.#{company_name.downcase.gsub(/\s+/, '')}.com"
    # If you have Active Storage for profile_picture, you could attach a file here.
  )
end

companies = Company.all
puts "Created #{companies.count} Companies."

puts "Assigning each user to a random company..."

# 6. Assign each user with random company:

users.each do |user|
  user.update!(company: companies.sample)
end

puts "Done assigning companies to users!"

# 6. Create Vacancies for each company:
#
#    - We pick random positions, locations, salaries, descriptions.
#    - We assign each vacancy to a random user as its creator.
#    - We create a random number of vacancies per company (3 to 7).

puts "Creating Vacancies..."

companies.each do |company|
  rand(3..7).times do
    Vacancy.create!(
      title: POSITIONS.sample,
      description: DESCRIPTIONS.sample,
      salary: SALARIES.sample,
      location: LOCATIONS.sample,
      employment_type: [ "Фулл-тайм", "Парт-тайм", "Стажировка" ].sample,
      company: company,
      user: users.sample  # pick any user at random
    )
  end
end

puts "Created #{Vacancy.count} Vacancies."

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

SECTION_TITLES = [
  "My Work",
  "Projects",
  "Education",
  "Skills",
  "Achievements"
]

puts "Creating random Sections and Cards for each user..."
users.each do |user|
  # Create 2-4 sections for each user
  num_sections = rand(1..2)

  num_sections.times do |section_index|
    section = user.sections.create!(
      title: SECTION_TITLES[section_index] || "Custom Section #{section_index + 1}",
      position: section_index + 1
    )

    # Create 3-5 cards for each section
    num_cards = rand(3..5)

    num_cards.times do |card_index|
      card_type = CARD_TYPES.sample
      section.cards.create!(
        card_type: card_type,
        title: generate_card_title(card_type),
        content: generate_card_content(card_type),
        url: (card_type == "link" ? "https://www.example.com" : nil),
        position: card_index + 1,  # simple ascending positions
        size: [ "square", "medium" ].sample
      )
    end
  end
end

puts "Created #{Section.count} Sections with #{Card.count} Cards."

puts "Creating image sections from folders..."

# This helper method creates a section for a user and populates it with image cards
# Parameters:
#   user: The User model instance who will own this section
#   folder_path: Path to the folder containing images
#   section_name: Name to use for the section title
def create_image_section(user, folder_path, section_name)
  # Don't create more than 6 sections per user
  if user.sections.count >= 6
    puts "Skipping section creation for #{user.name} - already has 6 sections"
    return
  end

  # Create a new section for this set of images
  # titleize converts names like "project_photos" to "Project Photos"
  section = user.sections.create!(
    title: section_name.titleize,
    position: user.sections.count + 1  # Place it after existing sections
  )

  # Find all image files in the specified folder
  # Select only files that end with image extensions
  images = Dir[File.join(folder_path, '*')].select { |f|
    File.file?(f) && f.match?(/\.(jpg|jpeg|png|gif)$/i)
  }

  # Create a card for each image in the folder
  images.each_with_index do |image_path, index|
    # Check the previous card's size to prevent consecutive medium cards
    previous_card = section.cards.find_by(position: index)
    # If previous card was medium, make this one square
    # Otherwise randomly choose between square and medium
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

# Set the base path where all image folders are located
# Rails.root.join creates a proper path for any operating system
base_path = Rails.root.join('db', 'seeds', 'images')

# Collect all paths to image folders
# We're looking for a structure like:
# - images/
#   - Category1/
#     - Subcategory1/
#     - Subcategory2/
#   - Category2/
#     - Subcategory3/
subcategory_paths = []
Dir[File.join(base_path, '*')].each do |category_path|
  next unless File.directory?(category_path)
  Dir[File.join(category_path, '*')].each do |subcategory_path|
    next unless File.directory?(subcategory_path)
    subcategory_paths << subcategory_path
  end
end

# Randomly distribute image sections among users
# We shuffle the paths to ensure random distribution of content
subcategory_paths.shuffle.each do |subcategory_path|
  # Find users who don't yet have 6 sections
  eligible_users = User.all.select { |user| user.sections.count < 6 }
  # Stop if all users have reached their section limit
  break if eligible_users.empty?

  # Pick a random eligible user for this section
  user = eligible_users.sample
  # Get the folder name to use as section title
  subcategory_name = File.basename(subcategory_path)
  # Create the section with its images
  create_image_section(user, subcategory_path, subcategory_name)
end

puts "Finished creating image sections!"

puts "Seed data created successfully!"
