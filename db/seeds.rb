# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
WikiProject.create([{ domain: 'commons.wikimedia.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: false }])
WikiProject.create([{ domain: 'wikinews.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: true }])
WikiProject.create([{ domain: 'wikipedia.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: true }])
WikiProject.create([{ domain: 'wikisource.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: true }])
WikiProject.create([{ domain: 'wikiversity.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: true }])
WikiProject.create([{ domain: 'wiktionary.org', article_path: '/wiki/', script_path: '/w/', has_language_subdomains: true }])
