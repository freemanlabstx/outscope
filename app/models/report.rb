require 'csv'

class Report < ApplicationRecord
  validates :title, presence: true
  validates :location, presence: true
  validates :term, presence: true
  validates :status, presence: true
  validates :report_type, presence: true

  enum :status, {created: 0, in_progress: 1, done: 2, failed: 3, archived: 4}
  # enum :report_type, {yelp: 0, google: 1}
  enum :report_type, {yelp: 0}
  has_prefix_id :report

  belongs_to :account
  # Broadcast changes in realtime with Hotwire
  after_create_commit -> { broadcast_prepend_later_to :reports, partial: "reports/index", locals: {report: self} }
  after_update_commit -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to :reports, target: dom_id(self, :index) }

  def reset!
    update!(
      data: nil,
      status: 0
    )
  end

  def parsed_data
    if data.nil?
      []
    else
      JSON.parse(data)
    end
  end

  def csv
    columns = ['name', 'rating', 'display_phone', 'address']
    CSV.generate do |csv|
      csv << columns
      parsed_data.each do |row|
        csv << columns.map do |column| 
          if column == 'address'
            row['location']['display_address'].join(' ')
          else
            row[column.to_s]
          end
        end
      end
    end
  end

  def self.business_types
    [
      "Accountants",
      "Acupuncture",
      "Advertising",
      "Air Conditioning Repair",
      "Animal Shelters",
      "Antique Shops",
      "Apartments",
      "Appliance Repair",
      "Appraisers",
      "Architects",
      "Art Galleries",
      "Attorneys",
      "Auto Detailing",
      "Auto Repair",
      "Bakeries",
      "Banks",
      "Barbers",
      "Bars",
      "Beauty Salons",
      "Bed & Breakfast",
      "Bicycle Repair",
      "Bookstores",
      "Breweries",
      "Building Supplies",
      "Bus Stations",
      "Butchers",
      "Cafes",
      "Car Dealers",
      "Car Wash",
      "Carpet Cleaning",
      "Caterers",
      "Chimney Sweeps",
      "Chiropractors",
      "Clothing Stores",
      "Coffee Shops",
      "Community Centers",
      "Computer Repair",
      "Concrete Contractors",
      "Construction Companies",
      "Convenience Stores",
      "Dance Studios",
      "Day Care",
      "Deck Builders",
      "Dentists",
      "Dermatologists",
      "Dry Cleaners",
      "Drywall Installation",
      "Electricians",
      "Electricians",
      "Employment Agencies",
      "Engineers",
      "Event Planning",
      "Excavation Services",
      "Farmers Markets",
      "Fence Contractors",
      "Financial Services",
      "Flooring Installation",
      "Florists",
      "Foundation Repair",
      "Furniture Assembly",
      "Furniture Stores",
      "Garage Door Services",
      "Garden Centers",
      "Gutter Cleaning",
      "Gyms",
      "HVAC Services",
      "Hair Salons",
      "Handyman Services",
      "Hardware Stores",
      "Health Clinics",
      "Heating Repair",
      "Home Inspectors",
      "Home Security Systems",
      "Hospitals",
      "Hotels",
      "House Cleaning",
      "IT Services",
      "Insurance Agencies",
      "Interior Design",
      "Interior Painters",
      "Irrigation Systems",
      "Jewelers",
      "Junk Removal",
      "Landscapers",
      "Laundromats",
      "Lawn Care",
      "Lawyers",
      "Libraries",
      "Locksmiths",
      "Marketing Agencies",
      "Masonry Contractors",
      "Massage Therapists",
      "Mechanics",
      "Medical Centers",
      "Movers",
      "Moving Companies",
      "Museums",
      "Music Stores",
      "Nail Salons",
      "Opticians",
      "Orthodontists",
      "Painters",
      "Painting Contractors",
      "Parks",
      "Party Supplies",
      "Paving Contractors",
      "Pest Control",
      "Pet Boarding",
      "Pet Groomers",
      "Pet Stores",
      "Pharmacies",
      "Photographers",
      "Physical Therapists",
      "Pizza Restaurants",
      "Plumbers",
      "Podiatrists",
      "Pool Cleaners",
      "Pool Cleaning",
      "Pressure Washing",
      "Printers",
      "Private Investigators",
      "Psychologists",
      "Public Relations",
      "Real Estate Agents",
      "Real Estate Appraisers",
      "Recreation Centers",
      "Recycling Centers",
      "Remodeling Contractors",
      "Restaurants",
      "Roofers",
      "Roofing Contractors",
      "Schools",
      "Screen Printing",
      "Security Systems",
      "Septic Services",
      "Shoe Repair",
      "Shoe Stores",
      "Skate Shops",
      "Social Media Marketing",
      "Solar Installation",
      "Solar Panel Installation",
      "Spa",
      "Specialty Schools",
      "Sporting Goods",
      "Sports Clubs",
      "Stucco Contractors",
      "Supermarkets",
      "Surveyors",
      "Swimming Pools",
      "Tailors",
      "Tattoo Shops",
      "Tax Services",
      "Telecommunications",
      "Tennis Clubs",
      "Theaters",
      "Thrift Stores",
      "Tile Installation",
      "Towing Services",
      "Toy Stores",
      "Travel Agencies",
      "Tree Services",
      "Tutoring",
      "Upholstery",
      "Veterinarians",
      "Video Production",
      "Water Damage Restoration",
      "Web Designers",
      "Wedding Planners",
      "Welding",
      "Wellness Centers",
      "Window Cleaning",
      "Window Installation",
      "Window Tinting",
      "Wine Stores",
      "Yoga Studios",
      "Zoos"
    ]
  end
end
