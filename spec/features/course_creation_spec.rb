require 'rails_helper'

def set_up_suite
  include Devise::TestHelpers, type: :feature
  Capybara.current_driver = :selenium
  page.current_window.resize_to(1920, 1080)
  stub_oauth_edit
end

def fill_out_course_creator_form
  fill_in 'Course title:', with: 'My course'
  fill_in 'Course term:', with: 'Spring 2016'
  fill_in 'Course school:', with: 'University of Oklahoma'
  find('input[placeholder="Start date (YYYY-MM-DD)"]').set(Date.new(2015, 1, 4))
  find('input[placeholder="End date (YYYY-MM-DD)"]').set(Date.new(2015, 2, 1))
  click_button 'Create my Course!'
end

def interact_with_clone_form
  fill_in 'Course term:', with: 'Spring 2016'
  fill_in 'Course description:', with: 'A new course'

  find('input[placeholder="Start date (YYYY-MM-DD)"]').set(course.start)
  find('input[placeholder="End date (YYYY-MM-DD)"]').set(course.end)

  within('.wizard__form') { click_button 'Save New Course' }

  within('.sidebar') { expect(page).to have_content(term) }
  within('.primary') { expect(page).to have_content(desc) }

  click_button 'Save This Course'
end

def go_through_course_dates_and_timeline_dates
  find('attr[title="Wednesday"]', match: :first).click
  within('.wizard__panel.active') do
    expect(page).to have_css('button.dark[disabled=""]')
  end
  find('.wizard__form.course-dates input[type=checkbox]', match: :first).set(true)
  within('.wizard__panel.active') do
    expect(page).not_to have_css('button.dark[disabled=disabled]')
  end
  click_button 'Next'
  sleep 1
end

def go_through_researchwrite_wizard
  go_through_course_dates_and_timeline_dates

  # Advance past the timeline date panel
  click_button 'Next'
  sleep 1

  # Choose researchwrite option
  find('.wizard__option', match: :first).find('button', match: :first).click
  click_button 'Next'
  sleep 1

  # Click through the offered choices
  find('.wizard__option', match: :first).find('button', match: :first).click # Training not graded
  click_button 'Next'
  sleep 1

  click_button 'Next' # Default getting started options
  sleep 1

  # Instructor prepares list
  find('.wizard__option', match: :first).find('button', match: :first).click
  click_button 'Next'
  sleep 1

  find('.wizard__option', match: :first).find('button', match: :first).click # Traditional outline
  click_button 'Next'
  sleep 1

  find('.wizard__option', match: :first).find('button', match: :first).click # Yes, medical articles
  click_button 'Next'
  sleep 1

  find('.wizard__option', match: :first).find('button', match: :first).click # Work live from start
  click_button 'Next'
  sleep 1

  click_button 'Next' # Default 2 peer reviews
  sleep 1

  click_button 'Next' # No supplementary assignments
  sleep 1

  click_button 'Next' # No DYK/GA
  sleep 1

  click_button 'Submit'
  sleep 1
end

describe 'New course creation and editing', type: :feature do
  before do
    set_up_suite
  end

  before :each do
    create(:cohort)
    user = create(:user,
                  id: 1,
                  permissions: User::Permissions::INSTRUCTOR)
    create(:training_modules_users, user_id: user.id,
                                    training_module_id: 3,
                                    completed_at: Time.now)
    login_as(user, scope: :user)

    visit root_path
  end

  describe 'course workflow', js: true do
    let(:expected_course_blocks) { 27 }
    let(:module_name) { 'Wikipedia Essentials' }

    it 'should allow the user to create a course' do
      click_link 'Create Course'

      expect(page).to have_content 'Create a New Course'
      find('#course_title').set('My awesome new course - Foo 101')

      # If we click before filling out all require fields, only the invalid
      # fields get restyled to indicate the problem.
      click_button 'Create my Course!'
      expect(find('#course_title')['class']).not_to include('invalid title')
      expect(find('#course_school')['class']).to include('invalid school')
      expect(find('#course_term')['class']).to include('invalid term')

      # Now we fill out all the fields and continue.
      find('#course_school').set('University of Wikipedia, East Campus')
      find('#course_term').set('Fall 2015')
      find('#course_subject').set('Advanced Studies')
      find('#course_expected_students').set('500')
      find('textarea').set('In this course, we study things.')

      # TODO: test the date picker instead of just setting fields
      start_date = '2015-01-01'
      end_date = '2015-12-15'
      find('input[placeholder="Start date (YYYY-MM-DD)"]').set(start_date)
      find('input[placeholder="End date (YYYY-MM-DD)"]').set(end_date)
      sleep 1

      # This click should create the course and start the wizard
      click_button 'Create my Course!'

      # Go through the wizard, checking necessary options.

      # This is the course dates screen
      sleep 3
      # validate either blackout date chosen
      # or "no blackout dates" checkbox checked
      expect(page).to have_css('button.dark[disabled=""]')
      start_input = find('input.start', match: :first).value
      expect(start_input).to eq(start_date)

      # capybara doesn't like trying to click the calendar
      # to set a blackout date
      go_through_course_dates_and_timeline_dates
      sleep 1

      # This is the timeline datepicker
      find('input.timeline_start').set(start_date)
      find('input.timeline_end').set(end_date)
      click_button 'Next'

      sleep 1

      # This is the assignment type chooser

      # pick and choose
      page.all('.wizard__option')[1].first('button').click
      sleep 1
      click_button 'Next'
      sleep 1
      # pick 2 types of assignments
      page.all('div.wizard__option__checkbox')[1].click
      page.all('div.wizard__option__checkbox')[3].click
      sleep 1
      click_button 'Next'

      # on the summary
      sleep 1
      # go back to the pick and choose and choose different assignments
      page.all('button.wizard__option.summary')[3].click
      sleep 1
      page.all('div.wizard__option__checkbox')[3].click
      page.all('div.wizard__option__checkbox')[2].click
      page.all('div.wizard__option__checkbox')[4].click
      sleep 1
      click_button 'Summary'
      sleep 1
      click_button 'Submit'

      # Now we're back at the timeline, having completed the wizard.
      sleep 1
      expect(page).to have_content 'Week 1'
      expect(page).to have_content 'Week 2'

      # Edit course dates and save
      click_link 'Edit Course Dates'
      find('attr[title="Thursday"]', match: :first).click
      sleep 1
      expect(Course.last.weekdays).to eq('0001100')
      click_link 'Done'
      sleep 1

      within('.week-1 .week__week-add-delete') do
        accept_confirm do
          find('.week__delete-week').click
        end
      end

      # There should now be 4 weeks
      expect(page).not_to have_content 'Week 5'

      # Click edit, mark a gradeable and save it.
      find('.week-1').hover
      sleep 0.5
      within('.week-1') do
        find('.block__edit-block').click
        find('p.graded input[type=checkbox]').set(true)
        sleep 1
        click_button 'Save'
      end
      sleep 1

      # Edit the gradeable.
      within('.grading__grading-container') do
        click_button 'Edit'
        sleep 1
        all('input').last.set('50')
        sleep 1
        click_button 'Save'
        sleep 1
        expect(page).to have_content 'Value: 50%'
      end

      # Navigate back to overview, check relevant data, then delete course
      visit "/courses/#{Course.first.slug}"

      within('.sidebar') do
        expect(page).to have_content I18n.t('courses.instructor.other')
      end

      accept_prompt(with: 'My awesome new course - Foo 101') do
        find('button.danger', match: :first).click
      end

      expect(page).to have_content 'Looks like you don\'t have any courses'
    end

    it 'should not allow a second course with the same slug' do
      create(:course,
             id: 10001,
             title: 'Course',
             school: 'University',
             term: 'Term',
             slug: 'University/Course_(Term)',
             submitted: 0,
             listed: true,
             passcode: 'passcode',
             start: '2015-08-24'.to_date,
             end: '2015-12-15'.to_date,
             timeline_start: '2015-08-31'.to_date,
             timeline_end: '2015-12-15'.to_date)

      click_link 'Create Course'
      expect(page).to have_content 'Create a New Course'
      find('#course_title').set('Course')
      find('#course_school').set('University')
      find('#course_term').set('Term')
      find('#course_subject').set('Advanced Studies')

      start_date = '2015-01-01'
      end_date = '2015-12-15'
      find('input[placeholder="Start date (YYYY-MM-DD)"]').set(start_date)
      find('input[placeholder="End date (YYYY-MM-DD)"]').set(end_date)
      sleep 1

      # This click should not successfully create a course.
      find('button.dark').click
      expect(page).to have_content 'This course already exists'
      expect(Course.all.count).to eq(1)
    end

    it 'should create a full-length research-write assignment' do
      create(:course,
             id: 10001,
             title: 'Course',
             school: 'University',
             term: 'Term',
             slug: 'University/Course_(Term)',
             submitted: 0,
             listed: true,
             passcode: 'passcode',
             start: '2015-08-24'.to_date,
             end: '2015-12-15'.to_date,
             timeline_start: '2015-08-31'.to_date,
             timeline_end: '2015-12-15'.to_date)
      create(:courses_user,
             user_id: 1,
             course_id: 10001,
             role: 1)

      # Visit timline and open wizard
      visit "/courses/#{Course.first.slug}/timeline/wizard"
      sleep 1

      go_through_researchwrite_wizard

      sleep 1

      expect(page).to have_content 'Week 14'

      # Now submit the course
      first('a.button').click
      prompt = page.driver.browser.switch_to.alert
      prompt.accept
      expect(page).to have_content 'Your course has been submitted.'

      Course.last.weeks.each_with_index do |week, i|
        expect(week.order).to eq(i + 1)
      end
      expect(Course.first.blocks.count).to eq(expected_course_blocks)
    end

    it 'should squeeze assignments into the course dates' do
      create(:course,
             id: 10001,
             title: 'Course',
             school: 'University',
             term: 'Term',
             slug: 'University/Course_(Term)',
             submitted: 0,
             listed: true,
             passcode: 'passcode',
             start: '2015-09-01'.to_date,
             end: '2015-10-09'.to_date,
             timeline_start: '2015-08-31'.to_date, # covers six calendar weeks
             timeline_end: '2015-10-09'.to_date)
      create(:courses_user,
             user_id: 1,
             course_id: 10001,
             role: 1)

      # Visit timline and open wizard
      visit "/courses/#{Course.first.slug}/timeline/wizard"
      sleep 1

      go_through_researchwrite_wizard

      expect(page).to have_content 'Week 6'
      expect(page).not_to have_content 'Week 7'
      expect(Course.first.blocks.count).to eq(expected_course_blocks)

      within ".week-1 .block-kind-#{Block::KINDS['assignment']}" do
        expect(page).to have_content module_name
      end
    end
  end

  describe 'returning instructor creating a new course', js: true do
    it 'should have the option of starting with no timeline' do
      pending 'fixing the intermittent failures on travis-ci'

      create(:course, id: 1)
      create(:courses_user,
             course_id: 1,
             user_id: 1,
             role: CoursesUsers::Roles::INSTRUCTOR_ROLE)

      click_link 'Create Course'
      click_button 'Create New Course'
      fill_out_course_creator_form
      sleep 1
      go_through_course_dates_and_timeline_dates

      # Advance past the timeline date panel
      first('button.dark').click
      sleep 1

      # Last option for returning instructor is 'build your own'
      find('button', text: 'Build your own timeline').click
      first('button.dark').click
      sleep 1

      # Proceed to the summary
      first('button.dark').click # Next
      sleep 1

      # Finish the wizard
      first('button.dark').click
      expect(page).to have_content 'Add Assignment'
      sleep 1

      # Add a week
      within '.timeline__week-nav .panel' do
        find('.week-nav__add-week').click
      end
      sleep 1
      within '.timeline__weeks' do
        expect(page).to have_content 'Week 1'
        within '.week-1' do
          find('.week__add-block').click
          find('input.title').set('block title')
          within('.block__block-actions') do
            click_button 'Save'
          end
          sleep 1
        end
      end
      # is it still there after reloading?
      visit current_path
      expect(page).to have_content 'Week 1'
      expect(page).to have_content 'block title'

      # Add Assignment button should not appear once there is timeline content.
      expect(page).not_to have_content 'Add Assignment'

      puts 'PASSED'
      fail 'this test passed — this time'
    end
  end

  after do
    logout
    Capybara.use_default_driver
  end
end

describe 'timeline editing', js: true do
  let!(:course) do
    create(:course, id: 10001, start: Date.new(2015, 1, 1),
                    end: Date.new(2015, 2, 1), submitted: true,
                    timeline_start: Date.new(2015, 1, 1), timeline_end: Date.new(2015, 2, 1),
                    weekdays: '0111110')
  end
  let!(:user)      { create(:user, permissions: User::Permissions::ADMIN) }
  let!(:c_user)    { create(:courses_user, course_id: course.id, user_id: user.id) }

  let!(:week)      { create(:week, course_id: course.id, order: 0) }
  let!(:week2)     { create(:week, course_id: course.id, order: 1) }
  let!(:block)     { create(:block, week_id: week.id, kind: Block::KINDS['assignment'], order: 0, title: 'Block 1') }
  let!(:block2)    { create(:block, week_id: week.id, kind: Block::KINDS['in_class'], order: 1, title: 'Block 2') }
  let!(:block3)    { create(:block, week_id: week.id, kind: Block::KINDS['in_class'], order: 2, title: 'Block 3') }
  let!(:block4)    { create(:block, week_id: week2.id, kind: Block::KINDS['in_class'], order: 0, title: 'Block 4') }
  let!(:block5)    { create(:block, week_id: week2.id, kind: Block::KINDS['in_class'], order: 1, title: 'Block 5') }
  let!(:block6)    { create(:block, week_id: week2.id, kind: Block::KINDS['in_class'], order: 3, title: 'Block 6') }

  before do
    set_up_suite
    create(:cohort)
    login_as user, scope: :user, run_callbacks: false
  end

  it 'disables reorder up/down buttons when it is the first or last block' do
    visit "/courses/#{Course.last.slug}/timeline"
    click_button 'Arrange Timeline'
    expect(find('.week-1 .week__block-list > li:first-child button:first-of-type')['disabled'])
      .to eq(nil)
    expect(find('.week-1 .week__block-list > li:first-child button:last-of-type')['disabled'])
      .to eq('true')
    expect(find('.week-2 .week__block-list > li:last-child button:first-of-type')['disabled'])
      .to eq('true')
    expect(find('.week-2 .week__block-list > li:last-child button:last-of-type')['disabled'])
      .to eq(nil)
  end

  it 'allows swapping places with a block' do
    visit "/courses/#{Course.last.slug}/timeline"
    click_button 'Arrange Timeline'
    find('.week-1 .week__block-list > li:nth-child(1) button:first-of-type').click # move down
    sleep 0.5
    find('.week-1 .week__block-list > li:nth-child(2) button:first-of-type').click # move down again
    sleep 0.5
    expect(find('.week-1 .week__block-list > li:nth-child(1)')).to have_content('Block 2')
    expect(find('.week-1 .week__block-list > li:nth-child(2)')).to have_content('Block 3')
    expect(find('.week-1 .week__block-list > li:nth-child(3)')).to have_content('Block 1')
    find('.week-1 .week__block-list > li:nth-child(3) button:last-of-type').click # move up
    sleep 0.5
    find('.week-1 .week__block-list > li:nth-child(2) button:last-of-type').click # move up again
    sleep 0.5
    expect(find('.week-1 .week__block-list > li:nth-child(1)')).to have_content('Block 1')
    expect(find('.week-1 .week__block-list > li:nth-child(2)')).to have_content('Block 2')
    expect(find('.week-1 .week__block-list > li:nth-child(3)')).to have_content('Block 3')
  end

  it 'allows moving blocks between weeks' do
    visit "/courses/#{Course.last.slug}/timeline"
    click_button 'Arrange Timeline'

    # move up to week 1
    find('.week-2 .week__block-list > li:nth-child(1) button:last-of-type').click
    sleep 0.5
    expect(find('.week-1 .week__block-list > li:nth-child(4)')).to have_content 'Block 4'

    # move back down to week 2
    find('.week-1 .week__block-list > li:nth-child(4) button:first-of-type').click
    sleep 0.5
    expect(find('.week-2 .week__block-list > li:nth-child(1)')).to have_content 'Block 4'
  end

  it 'allows user to save and discard changes' do
    visit "/courses/#{Course.last.slug}/timeline"
    click_button 'Arrange Timeline'

    # move up to week 1
    find('.week-2 .week__block-list > li:nth-child(1) button:last-of-type').click
    click_button 'Save All'
    expect(find('.week-1 .week__block-list > li:nth-child(4)')).to have_content 'Block 4'

    # move down to week 2 and discard Changes
    click_button 'Arrange Timeline'
    find('.week-1 .week__block-list > li:nth-child(4) button:first-of-type').click
    click_button 'Discard All Changes'
    # still in week 1
    expect(find('.week-1 .week__block-list > li:nth-child(4)')).to have_content 'Block 4'
  end
end

describe 'cloning a course', js: true do
  before do
    set_up_suite
  end

  let!(:course) do
    create(:course, id: 10001, start: 1.year.from_now.to_date,
                    end: 2.years.from_now.to_date, submitted: true)
  end
  let!(:week)      { create(:week, course_id: course.id) }
  let!(:block)     { create(:block, week_id: week.id, due_date: course.start + 3.months) }
  let!(:gradeable) do
    create(:gradeable, gradeable_item_type: 'block', gradeable_item_id: block.id, points: 10)
  end
  let!(:user)      { create(:user, permissions: User::Permissions::ADMIN) }
  let!(:c_user)    { create(:courses_user, course_id: course.id, user_id: user.id) }
  let!(:term)      { 'Spring 2016' }
  let!(:desc)      { 'A new course' }

  it 'copies relevant attributes of an existing course' do
    pending 'fixing the intermittent failures on travis-ci'
    create(:cohort)
    login_as user, scope: :user, run_callbacks: false
    visit root_path

    click_link 'Create Course'
    click_button 'Clone Previous Course'
    select course.title, from: 'reuse-existing-course-select'
    click_button 'Clone This Course'

    expect(page).to have_content 'Course Successfully Cloned'

    # interact_with_clone_form

    # form not working right now
    visit "/courses/#{Course.last.slug}"
    course.reload

    new_course = Course.last
    expect(Week.count).to eq(2) # make sure the weeks are distinct
    expect(new_course.blocks.first.content).to eq(course.blocks.first.content)
    expect(new_course.blocks.first.due_date)
      .to be_nil
    expect(new_course.blocks.first.gradeable.points).to eq(gradeable.points)
    expect(new_course.blocks.first.gradeable.gradeable_item_id)
      .to eq(new_course.blocks.first.id)
    expect(new_course.instructors.first).to eq(user)
    expect(new_course.submitted).to eq(false)
    expect(new_course.user_count).to be_zero
    expect(new_course.article_count).to be_zero

    puts 'PASSED'
    fail 'this test passed — this time'
  end

  after do
    logout
    Capybara.use_default_driver
  end
end
