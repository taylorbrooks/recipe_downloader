require 'gastly'

class RecipePage
  def self.screenshot(uuid, name = 'output', meal = 'breakfast')
    new(uuid, name, meal).fetch
  end

  def initialize(uuid, name, meal)
    @uuid = uuid
    @name = name
    @meal = meal
  end

  def fetch
    url = "https://meals.richroll.com/recipe/#{@uuid}"
    screenshot = Gastly.screenshot(url)
    screenshot.browser_height = 2500
    screenshot.cookies = { auth: ENV['COOKIE']}
    image = screenshot.capture
    image.format('png')
    image.save("./images/#{@meal}/#{@name.downcase}.png")
  end
end
