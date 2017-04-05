# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# City.create!(city: "Berkeley")
# Category.create!(title: "Appliances")
# City.create!(name: "Santa Clara")
# City.create!(name: "San Jose")
# City.create!(name: "San Fransisco")
# City.create!(name: "Sacramento")
# City.create!(name: "Palo Alto")
# City.create!(name: "Berkeley")
# City.create!(name: "Fremont")
# City.create!(name: "Oakland")

# State.create!(name: "CA")

Category.create!(title: "Automobiles")
Category.create!(title: "Antiques")
Category.create!(title: "Appliances")
Category.create!(title: "Arts & Crafts")
Category.create!(title: "Audio Equipment")
Category.create!(title: "Baby & Kids")
Category.create!(title: "Books & Magazines")
Category.create!(title: "Bicycles")
Category.create!(title: "Boats")
Category.create!(title: "Beauty & Health")
Category.create!(title: "Clothing & Shoes")
Category.create!(title: "Computers & Electronics")
Category.create!(title: "Campers & RVs")
Category.create!(title: "Cell Phones")
Category.create!(title: "Events")
Category.create!(title: "Farming")
Category.create!(title: "Food & Beverages")
Category.create!(title: "Furniture")
Category.create!(title: "Games & Toys")
Category.create!(title: "Housing")
Category.create!(title: "Household")
Category.create!(title: "Jobs & Services")
Category.create!(title: "Jewelry & Accessories")
Category.create!(title: "Medicine")
Category.create!(title: "Sports & Outdoors")
Category.create!(title: "Tickets")
Category.create!(title: "Tools & Machinery")
Category.create!(title: "Video Equipment")
Category.create!(title: "Pets & Pet Supplies")
Category.create!(title: "Photography")
Category.create!(title: "Cleaning")

#computer type
Category.create!(title: "Hardware")
Category.create!(title: "Software")

#electronics type
Category.create!(title: "Desktops")
Category.create!(title: "Laptops")
Category.create!(title: "TVs")

#car types
Category.create!(title: "Trucks")
Category.create!(title: "SUVs")
Category.create!(title: "Sedans")
Category.create!(title: "Motorcycles")

# seasons
Category.create!(title: "Winter")
Category.create!(title: "Fall")
Category.create!(title: "Spring")

#jobs, intenrships, work etc.

# companies
Category.create!(title: "Apple")
Category.create!(title: "Microsoft")
Category.create!(title: "T-Mobile")
Category.create!(title: "AT&T")
Category.create!(title: "Verizon")

# operating system
Category.create!(title: "IOS")
Category.create!(title: "Android")
Category.create!(title: "Windows")
Category.create!(title: "Mac")

# body related

# Genders



2.times do |n|
  first_name  = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = "example-#{n+1}@railstutorial.org"
  password = "05090127"
  User.create!(first_name:  first_name,
               last_name:  last_name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
 # user = User.first
 # user.posts.create!(subject:"test0", price:42,content:"this is just testing!! For the win!", street_address:"random",city:"San Francisco",state:"CA",payment_method:"Cash",condition:"New")
 # user.posts.create!(subject:"test1", price:42,content:"this is just testing! please help me out",street_address:"random",city:"San Francisco",state:"CA",payment_method:"Cash",condition:"New")
end

# users = User.order(:created_at)
# 10.times do
#   subject = Faker::Commerce.product_name
#   content = Faker::Lorem.sentence(10)
#   street_address = Faker::Address.street_address
#   city = "San Fransisco"
#   state = "California"
#   zip = Faker::Address.zip
#   price = Faker::Number.decimal(2)
#   users.each { |user| user.posts.create!(subject: subject, street_address: street_address, city: city, state: state, zip: zip, price: price, content: content) }
# end
