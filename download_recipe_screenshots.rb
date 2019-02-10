require 'json'
require './recipe_page.rb'

def screenshot_recipes(recipes, meal)
  Parallel.each(recipes, in_threads: 8) do |r|
    name = r['name']
             .downcase
             .strip
             .gsub(' ', '-')
             .gsub(',', '')
             .gsub('&', 'and')
    RecipePage.screenshot(r['id'], name, meal)
  end
end

meals = %w(breakfast lunch dinner)

breakfast, lunch, dinner = meals.map do |meal|
  JSON.parse(File.read("./json/#{meal}.json"))
end

meals.each { |meal| screenshot_recipes(eval(meal), meal) }
