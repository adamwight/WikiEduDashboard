require 'rails_helper'
require "#{Rails.root}/lib/cleaners"

describe Cleaners do
  describe '.remove_bad_articles_courses' do
    it 'should remove ArticlesCourses that do not belong' do
      create(:course,
             id: 1,
             start: Date.today - 1.month,
             end: Date.today + 1.month,
             title: 'Underwater basket-weaving')
      create(:user,
             id: 1)
      # A user who is not a student, so they should not have ArticlesCourses
      create(:courses_user,
             course_id: 1,
             user_id: 1,
             role: 2)
      create(:article,
             id: 1)
      create(:revision,
             user_id: 1,
             article_id: 1,
             date: Date.today)
      # An ArticlesCourse that should be removed
      create(:articles_course,
             course_id: 1,
             article_id: 1)

      Cleaners.remove_bad_articles_courses
      expect(ArticlesCourses.all.count).to eq(0)
    end
  end

  describe '.repair_orphan_revisions' do
    it 'should import articles for orphaned revisions' do
      # We start with revision and article
      create(:revision,
             id: 661324615,
             article_id: 46640378,
             user_id: 24593901,
             date: '2015-05-07 23:22:33')
      create(:article,
             id: 46640378,
             namespace: 0)
      create(:user,
             id: 24593901,
             wiki_id: 'Rothscak')
      create(:courses_user,
             course_id: 1,
             user_id: 24593901)
      create(:course,
             id: 1,
             start: '2015-01-01',
             end: '2016-01-01')
      ArticlesCourses.update_from_revisions
      # Now the id of the articles changes via
      # ArticleImporter.update_article_status, but the process duplicates
      # before the orphaned revisions get processed in the normal way.
      article = Article.find(46640378)
      article.id = 2
      article.save

      # Now ArticlesCourses.update_all_caches will break until the revisions
      # are de-orphaned (issue #93). So let's try to de-orphan them.
      Cleaners.repair_orphan_revisions
      ArticlesCourses.update_from_revisions
      ArticlesCourses.update_all_caches
    end
  end

  describe '.rebuild_articles_courses' do
    it 'should create ArticlesCourses for current students' do
      create(:course,
             id: 1,
             start: 1.month.ago,
             end: Date.today + 1.year)
      create(:revision,
             id: 661324615,
             article_id: 46640378,
             user_id: 24593901,
             date: 1.day.ago)
      create(:article,
             id: 46640378,
             namespace: 0)
      create(:user,
             id: 24593901,
             wiki_id: 'Rothscak')
      create(:courses_user,
             course_id: 1,
             user_id: 24593901)
      Cleaners.rebuild_articles_courses
      articles_for_course = ArticlesCourses.where(course_id: 1)
      expect(articles_for_course.count).to eq(1)
    end
  end
end