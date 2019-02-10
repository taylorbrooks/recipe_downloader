require './recipe.rb'

meals = %w(breakfast lunch dinner)
meals.map { |meal| Recipe.fetch(meal) }
