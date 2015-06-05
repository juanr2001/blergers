require 'pry'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "blergers/version"
require 'blergers/init_db'
require 'blergers/importer'

module Blergers
  class Post < ActiveRecord::Base
    has_many :post_tags
    has_many :tags, through: :post_tags

#Post.page(n) to return a page of blog results in reverse chronological order. I suggest pages of size 10. I.e.
# Post.page(1) should return the last 10 posts I wrote, Post.page(2) should return the next 10 posts after that.

  def self.page(n)
    Post.select(:date).limit(10).order(date: :desc).offset(n)
  #page_size = 10
  #page_offset = (n -1)* page_size
  #Post.order(date: :desc).offset(page_offset).limit(page_size)
  end

# Tag.top_tags to print a ranking of the tags from most commonly used
# to least commonly used, similar to last night's "scoreboard".
  def self.top_tags
    #Blergers::Tag.all.map {|x| [x.name, x.post.count]}.sort_by {|x| x[1]}.reverse (Doing this using ruby)

    #Blergers::Tag.joins(:post_tags).
    #group_by {|x| x.name}.
    #map {|k, v| [k,v.length]}.
    #sort_by {|x| x[1]}.
    #reverse

    #Tag.joins(:post_tags).group("tags.name").count.sort_by {|x| x[1]}.reverse

    Tag.joins(:post_tags).group("tags.name").order("count_all DESC").count
  end
  #hard mode
  def self.count_tagged_with(*tags_name)
    Tag.joins(:post_tags).where(name: tags_name).goup(:post_id).count.count


  end


  end



  class Tag < ActiveRecord::Base
    has_many :post_tags
    has_many :posts, through: :post_tags
  end

  class PostTag < ActiveRecord::Base
    belongs_to :post
    belongs_to :tag
  end
end

def add_post!(post)
  puts "Importing post: #{post[:title]}"

  tag_models = post[:tags].map do |t|
    Blergers::Tag.find_or_create_by(name: t)
  end
  post[:tags] = tag_models

  post_model = Blergers::Post.create(post)
  puts "New post! #{post_model}"
end



def run!
  blog_path = '/Users/brit/projects/improvedmeans'
  toy = Blergers::Importer.new(blog_path)
  toy.import
  toy.posts.each do |post|
    add_post!(post)
  end
end

binding.pry
