# _plugins/category_pages.rb
module Jekyll
  class CategoryPageGenerator < Generator
    safe true

    def slugify(category)
      category.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    def generate(site)
      category_configs = site.config['category_pages'] || []

      category_configs.each do |config|
        collection_name = config['collection']
        collection = site.collections[collection_name]
        next if collection.nil?

        url_template = config['url_structure']
        layout = config['layout']

        category_pages = {}

        collection.docs.each do |doc|
          categories = Array(doc.data['category'])
          categories += Array(doc.data['categories'])
          categories.uniq!
          categories.compact!
        
          categories.each do |category|
            category_slug = slugify(category)
            category_pages[category_slug] ||= CategoryPage.new(site, collection, category, url_template, layout)
            category_pages[category_slug].data['items'] << doc
            category_pages[category_slug].data['titletag'] = config['seo_title'].gsub(':category', category)
            category_pages[category_slug].data['description'] = config['seo_description'].gsub(':category', category)
          end
        end

        category_pages.each_value { |page| site.pages << page }
      end
    end
  end

  class CategoryPage < Page
    def initialize(site, collection, category, url_template, layout)
      @site = site
      @base = site.source
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), "#{layout}.html")

      self.data['title'] = category
      self.data['items'] = []

      url = url_template.gsub(':collection', collection.label).gsub(':category', category.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, ''))
      self.data['permalink'] = url
    end
  end
end
