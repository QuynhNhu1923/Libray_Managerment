# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
  name: "Example User",
  email: "example@example.com",
  password: "password",
  password_confirmation: "password",
  age: 25,
  phone: "0123456789",
  date_of_birth: Date.new(2000, 1, 1),
  gender: "male",
  admin: true,
  activated: true, 
  activated_at: Time.zone.now
)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  gender = ["male", "female", "other"].sample
  date_of_birth = Faker::Date.birthday(min_age: 18, max_age: 65)
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    gender: gender,
    date_of_birth: date_of_birth,
    activated: true, 
    activated_at: Time.zone.now
  )
end
