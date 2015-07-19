require "#{Rails.root}/lib/utils"
require "#{Rails.root}/lib/importers/view_importer"
require "#{Rails.root}/lib/importers/article_importer"

#= Article model
class Article < ActiveRecord::Base
  has_many :revisions
  has_many :editors, through: :revisions, source: :user
  has_many :articles_courses, class_name: ArticlesCourses
  has_many :courses, -> { uniq }, through: :articles_courses
  has_many :assignments

  belongs_to :wiki_projects

  scope :live, -> { where(deleted: false) }
  scope :current, -> { joins(:courses).merge(Course.current).uniq }
  scope :namespace, -> ns { where(namespace: ns) }

  # Always save titles with underscores instead of spaces, since that's the way
  # they are in the MediaWiki database.
  validates :title, presence: true
  before_validation do
    self.title = title.gsub(' ', '_')
  end
  ####################
  # Instance methods #
  ####################
  def update(data={}, save=true)
    self.attributes = data
    if revisions.count > 0
      self.views = revisions.order('date ASC').first.views || 0
    else
      self.views = 0
    end
    self.save if save
  end

  #################
  # Cache methods #
  #################
  def character_sum
    update_cache unless self[:character_sum]
    self[:character_sum]
  end

  def revision_count
    self[:revision_count] || revisions.size
  end

  def update_cache
    # Do not consider revisions with negative byte changes
    self.character_sum = revisions.where('characters >= 0').sum(:characters)
    self.revision_count = revisions.size
    save
  end

  #################
  # Class methods #
  #################
  def self.update_all_caches(articles=nil)
    Utils.run_on_all(Article, :update_cache, articles)
  end
end
