class Course < ActiveRecord::Base
  # Has many relationships
  has_many :comments
  has_many :votes, as: :votable
  has_many :entries

  default_scope { where(available: true) }
  scope :show_all, -> { unscope(where: :available) }
  scope :by_title, -> search { where("title LIKE ?", "%#{search}%") }
  scope :by_instructor, -> search { where("instructor LIKE ?", "%#{search}%") }
  scope :by_department, -> search { joins(:entries).where("entries.department LIKE ?", "%#{search}%").uniq }
  scope :by_category, -> search { where(category: search) }

  def available?
    self[:available]
  end
end
