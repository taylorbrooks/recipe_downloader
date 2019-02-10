require 'faraday'
require 'faraday_middleware'
require 'json'
require 'parallel'

class Recipe
  def self.fetch(query)
    new(query).fetch
  end

  attr :query

  def initialize(query)
    @query = query
    @uuids = []
  end

  def fetch
    fetch_uuids

    recipes = Parallel.map(@uuids, in_threads: 8) do |uuid|
      p "fetching #{uuid[:name]}"
      connection.get("recipes/#{uuid[:id]}").body
    end

    File.open("./json/#{query}.json", 'w') do |f|
      f.write(JSON.pretty_generate(recipes))
    end
  end

  def fetch_uuids
    first_page  = search
    pages_count = first_page['total'] / first_page['hits'].size

    @uuids << uuids_from_page(first_page)

    Parallel.each(1..pages_count, in_threads: 8) do |i|
      page = search(i)

      p "fetching #{i}"
      @uuids << uuids_from_page(page)
    end

    @uuids = @uuids.flatten!(1).uniq { |r| r[:name] }
  end

  def uuids_from_page(page)
    page['hits'].flat_map do |recipe|
      {
        id: recipe['id'],
        name: recipe['name'].strip
      }
    end
  end

  def search(page = 0)
    connection.get("search/#{query}/#{page}").body
  end

  private

  def connection
    Faraday.new(
      url: 'https://meals.richroll.com/api/',
      headers: {
        'User-Agent' => 'Cool Hand Luke ;)',
        accept: 'application/json',
        cookie: "auth=#{ENV['COOKIE']}"
      }
    ) do |conn|
      conn.request  :json
      conn.response :json
      conn.adapter  Faraday.default_adapter
    end
  end
end
