module Jekyll
  class CollectionArchiveGenerator < Generator
    safe true

    def generate(site)
      collections_to_archive = site.config['collections_with_archives'] || []

      collections_to_archive.each do |collection_config|
        collection_name = collection_config['name']
        layout = collection_config['layout']
        archive_types = collection_config['archive_type'] || []
        monthly_archive_slug = collection_config['monthly_archive_slug'] || "/blog/:collection_name/monthly/:year/:month/"
        yearly_archive_slug = collection_config['yearly_archive_slug'] || "/blog/:collection_name/yearly/:year/"

        if site.collections.key?(collection_name)
          collection = site.collections[collection_name]

          if archive_types.include?('monthly')
            # Generate monthly archives
            posts_grouped_by_month(site, collection).each do |period, posts|
              year, month = period.split('-')
              archive_dir = monthly_archive_slug.gsub(':collection_name', collection_name)
                                                .gsub(':year', year)
                                                .gsub(':month', month)
              site.pages << CollectionArchive.new(site, site.source, archive_dir, period, posts, collection_name, layout)
            end
          end

          if archive_types.include?('yearly')
            # Generate yearly archives
            posts_grouped_by_year(site, collection).each do |year, posts|
              archive_dir = yearly_archive_slug.gsub(':collection_name', collection_name)
                                               .gsub(':year', year.to_s)
              site.pages << CollectionArchive.new(site, site.source, archive_dir, year.to_s, posts, collection_name, layout)
            end
          end

        else
          Jekyll.logger.warn "Warning:", "Collection '#{collection_name}' not found. Skipping archive generation."
        end
      end
    end

    def posts_grouped_by_month(site, collection)
      collection.docs.group_by { |post| post.date.strftime('%Y-%m') }
    end

    def posts_grouped_by_year(site, collection)
      collection.docs.group_by { |post| post.date.year }
    end
  end

  class CollectionArchive < Page
    def initialize(site, base, dir, period, posts, collection, layout)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "#{layout}.html")
      self.data['period'] = period
      self.data['posts'] = posts
      self.data['collection'] = collection
    end
  end
end
