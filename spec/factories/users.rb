# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  wiki_id             :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  character_sum       :integer          default(0)
#  view_sum            :integer          default(0)
#  course_count        :integer          default(0)
#  article_count       :integer          default(0)
#  revision_count      :integer          default(0)
#  trained             :boolean          default(FALSE)
#  global_id           :integer
#  remember_created_at :datetime
#  remember_token      :string(255)
#  wiki_token          :string(255)
#  wiki_secret         :string(255)
#  permissions         :integer          default(0)
#  real_name           :string(255)
#  email               :string(255)
#  onboarded           :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :test_user, class: User do
    wiki_id 'Pizza'
    onboarded true
  end

  factory :user do
    id '4543197'
    wiki_id 'Ragesock'
    onboarded true
    association :home_wiki, factory: :wiki
  end

  factory :trained, class: User do
    id '319203'
    wiki_id 'Ragesoss'
    onboarded true
  end

  factory :admin, class: User do
    id '1'
    wiki_id 'Ragesauce'
    permissions '1'
    onboarded true
  end
end
