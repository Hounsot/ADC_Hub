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
  "We’re looking for someone who is passionate about technology and ready to push boundaries.",
  "As part of our team, you’ll be working on cutting-edge solutions for modern businesses.",
  "Join us and help shape the future of our industry with creativity and innovation.",
  "In this role, you will collaborate with cross-functional teams to deliver high-quality results.",
  "We value work-life balance and offer a flexible environment for our employees."
]

USERNAMES = [
  "alice",
  "bob",
  "charlie",
  "dave",
  "eve"
]

EMAILS = [
  "alice@example.com",
  "bob@example.com",
  "charlie@example.com",
  "dave@example.com",
  "eve@example.com"
]

# 2. (Optional) Clear existing data to avoid duplicates:
#    Uncomment these lines if you want a fresh start each time you run seeds:
#
Vacancy.destroy_all
Company.destroy_all
User.destroy_all

# 3. Create a few Users (if you don't already have them):
puts "Creating Users..."

# We assume Devise or similar is used, requiring an email and password.
# We'll just create 5 example users.
USERNAMES.each_with_index do |username, i|
  User.create!(
    email: EMAILS[i],
    password: "password"
  )
end

users = User.all
puts "Created #{users.count} Users."

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

# 5. Create Vacancies for each company:
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

puts "Seed data created successfully!"
