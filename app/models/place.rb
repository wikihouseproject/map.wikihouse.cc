class Place < ApplicationRecord
  validates_presence_of :lat, :lng, :name

  include Workflow

  workflow do
    state :awaiting_review do
      event :accept, transitions_to: :accepted
      event :reject, transitions_to: :rejected
    end

    state :accepted do
      event :reject, transitions_to: :rejected
    end

    state :rejected do
      event :accept, transitions_to: :accepted
    end
  end

  def self.policy_class
    PlacePolicy
  end

  def self.icon
    raise NotImplementedError, "specify the name of a font-awesome icon"
  end

  class_attribute :fields
  self.fields = []

  def self.field(name)
    name = name.to_s
    self.fields += [name]

    define_method name do
      data[name]
    end

    define_method "#{name}=" do |value|
      data[name] = value
    end

    define_method "#{name}?" do
      data[name].present?
    end
  end

  field :description
  field :links

  has_attached_file :image, styles: { normal: "300x300>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  def icon
    self.class.icon
  end

  def to_s
    name
  end

  def safe_latlng(precision=2)
    # https://en.wikipedia.org/wiki/Decimal_degrees#Precision
    # 2: ~ 500m-1km precision
    # 3: ~ 50-100m precision
    [lat,lng].map{|f| sprintf("%.#{precision}f", f)}
  end

  def data
    super || (self.data = {})
  end

  def link_list
    links.to_s.split(/[\s,]+/)
  end
end
