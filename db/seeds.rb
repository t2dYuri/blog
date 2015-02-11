# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name: 'Admin Yuri Trend',
             email: 't2d.yuri@gmail.com',
             password:              'polikpol',
             password_confirmation: 'polikpol',
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name: 'Пользователь Будулай',
             email: 'test@mail.com',
             password:              'polikpol',
             password_confirmation: 'polikpol',
             activated: true,
             activated_at: Time.zone.now)


50.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = 'password'
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(created_at: :asc).take(6)
20.times do
  filltitle = Faker::Lorem.sentence
  filldescription = Faker::Lorem.paragraph(7)
  filltext = Faker::Lorem.paragraph(20)
  users.each { |user| user.articles.create!(title: filltitle, description: filldescription, text: filltext) }
end

users = User.all
user  = users.last
following = users[2..45]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
