class Agency < ApplicationRecord
  require 'csv'
  has_many :websites, dependent: :destroy
  accepts_nested_attributes_for :websites
  has_many :agency_categories
  has_many :categories, through: :agency_categories
  validates :name, presence: true, uniqueness: { scope: [:address, :city, :state, :zipcode],
    message: "should have different address" }
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.full_address.present? && obj.address_changed? }
  include PgSearch

  pg_search_scope :search_name, against: %i[name address state city zipcode description descripcion],
                                associated_against: { categories: %i[name categoria] },
                                ignoring: :accents

  def upcase_fields
    state.upcase!
  end

  def full_address
    [address, city, state, zipcode].compact.join(', ')
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|

      hash = row.to_hash
      next if hash.empty?
      agency = Agency.find_or_create_by(
                name:        hash["name"],
                address:     hash["address"],
                city:        hash["city"],
                state:       hash["state"],
                zipcode:     hash["zipcode"]
              )
      agency.update_attributes( contact:     hash["contact"],
                                email:       hash["email"],
                                phone:       hash["phone"],
                                description: hash["description"],
                                descripcion: hash["descripcion"]
                                )

      next unless agency.save
      # Agency site
      @agency_site = agency.websites.find_by(url:          'http://' + hash["agency_url"],
                                             website_type: WebsiteType.find_by(name: "Website")
                                            )
      if @agency_site.present?

      else
        agency.websites.create(url:          hash["agency_url"],
                               website_type: WebsiteType.find_by(name: "Website")
                              )
      end

      # Facebook site
      @facebook_site = agency.websites.find_by(url:         'http://' + hash["facebook_url"],
                                               website_type: WebsiteType.find_by(name: "Facebook")
                                              )
      if @facebook_site.present?

      else
        agency.websites.create(url:          hash["facebook_url"],
                               website_type: WebsiteType.find_by(name: "Facebook")
                              )
      end

      # Category
      @category = Category.find_or_create_by(name: hash["cat_name"],
                                             categoria: hash["categoria"],
                                             fa_name: hash["fa_name"]
                                            )
      agency_category = agency.agency_categories.find_or_create_by(category_id: @category.id)

    end
  end

  def new_agency_hash
    category_array = []
    website_array = []

    self.categories.each do |cat|
      category_array << { name: cat.name, categoria: cat.categoria, fa_name: cat.fa_name }
    end

    self.websites.each do |web|
      website_array << { name: web.website_type.name, url: web.url }
    end

    { name: self.name,
      address: self.address,
      city: self.city,
      state: self.state,
      zipcode: self.zipcode,
      contact: self.contact,
      email: self.email,
      phone: self.phone,
      description: self.description,
      descripcion: self.descripcion,
      categories: category_array,
      websites: website_array
    }
  end
end
