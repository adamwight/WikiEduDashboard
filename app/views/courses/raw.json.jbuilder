json.course do
  json.(@course, :id, :title, :description, :start, :end, :school,
                 :term, :subject, :slug, :url, :listed, :submitted, :listed,
                 :passcode)

  json.legacy @course.id < 10000

  json.created_count number_to_human @course.revisions.joins(:article).where(articles: {namespace: 0}).where(new_article: true).count
  json.edited_count number_to_human @course.article_count
  json.edit_count number_to_human @course.revisions.count
  json.student_count @course.user_count
  json.trained_count @course.users.role('student').where(trained: true).count
  json.character_count number_to_human @course.character_sum
  json.view_count number_to_human @course.view_sum

  json.published CohortsCourses.exists?(course_id: @course.id)
  json.passcode @course.passcode if user_signed_in? && current_user.role(@course) > 0
end