# Multi Collection Archives Plugin for Jekyll

This plugin allows you to create archives for your Jekyll collections on a monthly and yearly basis. The archives are sorted based on the date of the posts and are created dynamically when your site builds.

### Installation

To install this plugin, follow the steps below:

1.  Copy the plugin file `multi_collection_archives.rb` to your `_plugins` directory in your Jekyll project.
2.  Ensure your Jekyll version is compatible with this plugin. This plugin has been tested with Jekyll 4.0.

### Usage

To use this plugin, you need to specify which collections you want to archive in your `_config.yml` file under the `collections_with_archives` key. The value should be an array of collection configurations. Each configuration is a hash that should contain the following keys:

-   `name`: The name of the collection you want to archive.
-   `layout`: The layout you want to use for the archive page.
-   `archive_type`: An array that can contain either or both `monthly` and `yearly` indicating the type of archives you want to create.
-   `monthly_archive_slug` and `yearly_archive_slug`: The URL structure you want for your archive pages.

Here is an example configuration:

```
collections_with_archives:
  - name: blogposts
    layout: archive
    archive_type:
      - monthly
    monthly_archive_slug: "/:year/:month/"`
```

In this example, the plugin will create monthly archives for the `blogposts` collection using the `archive` layout.

The URL for the archives will be in the format "/:year/:month/". You can customize this URL structure by replacing `:year`, `:month`, and `:collection_name` with the desired structure. For example, `/blog/:collection_name/monthly/:year/:month/` would create URLs like `/blog/blogposts/monthly/2023/06/`.

### Layout

The archive pages use a layout specified in the configuration. In the example above, we used an `archive` layout.

The layout should be a .html file in your `_layouts` directory. It should contain Liquid template code to display the posts for that period.

**Note:** You'll have to always use `page.posts` to loop through to collection items for the archive

The page object in the layout will contain the following data:

-   `period`: The period for this archive in the format "YYYY-MM" for monthly archives and "YYYY" for yearly archives.
-   `posts`: An array of post objects for this period.
-   `collection`: The name of the collection.

### Layout Example

Here's an example of a layout (`archive.html`) used for the archive pages:

```
{% assign date_parts = page.period | split: "-" %}
{% assign year = date_parts[0] %}
{% assign month_number = date_parts[1] | plus: 0 | minus: 1 %}
{% assign months = 'January February March April May June July August September October November December' | split: ' ' %}
{% assign month_name = months[month_number] %}
<h2 class="page-title"><b>{{month_name}} {{year}} Articles</b></h2>

{% for post in page.posts reversed %}
  {% assign today_date = 'now' | date: "%Y-%m-%d" %}
  {% assign post_date = post.date | date: "%Y-%m-%d" %}
    {% if post_date <= today_date %}
      <article category="{{ post.category }}">
        <img src="{{ post.featuredImage }}" alt="{{ post.imageAltTag }}">
        <h2><a href="{{ post.url }}">{{ post.h1Headline }}</a></h2>
        <div class="post-meta">
            <p>{{ post.date | date_to_long_string }}</p> | <a
            href="/category/{{ post.category | slugify }}/">{{ post.category }}</a>
        </div>
        <p>{{ post.content | strip_html | truncatewords: 25 | markdownify }}</p>
        <a class="button" href="{{ post.url }}">Continue Reading</a>
      </article>
    {% endif %}

  {% endif %}
{% endfor %}
```

In this example, the layout first calculates the human-readable month name from the `page.period` value. It then iterates over each post in the archive and includes the post using the `blog-post.html` include.

This layout makes use of the `page.period` and `page.posts` variables provided by the Multi Collection Archives Plugin. `page.period` is a string representation of the month and year of the archive (format: 'YYYY-MM' for monthly archives, 'YYYY' for yearly archives). `page.posts` is an array of the posts in this archive.

Note: The layout assumes that you have a `_includes/blog-post.html` file that specifies how each blog post should be displayed. You'll need to create this file according to your site's design if you don't already have one.

### Errors and Warnings

In case the specified collection does not exist, the plugin logs a warning and skips the archive generation for that collection.
