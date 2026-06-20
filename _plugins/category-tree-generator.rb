#!/usr/bin/env ruby
#
# Build category trees by language from visible posts.

module Jekyll
  class CategoryTreeGenerator < Generator
    safe true
    priority :low

    def generate(site)
      trees = Hash.new { |h, k| h[k] = {} }

      site.posts.docs.each do |post|
        next if hidden?(post)
        next if local_only?(post) && Jekyll.env != 'development'

        lang = (post.data['post_lang'] || 'kr').to_s
        categories = Array(post.data['categories']).map(&:to_s).reject(&:empty?)
        next if categories.empty?

        cursor = trees[lang]
        categories.each do |name|
          cursor[name] ||= { 'name' => name, 'count' => 0, 'children' => {}, 'posts' => [] }
          cursor[name]['count'] += 1
          cursor[name]['posts'] << {
            'title' => post.data['title'].to_s,
            'url' => post.url.to_s,
            'date' => post.date
          }
          cursor = cursor[name]['children']
        end
      end

      site.config['category_tree_by_lang'] = trees.transform_values { |tree| normalize(tree, []) }
    end

    private

    def normalize(node_hash, ancestors)
      node_hash.keys.sort.map do |key|
        node = node_hash[key]
        path = ancestors + [node['name']]
        slug = path.map { |part| Jekyll::Utils.slugify(part.to_s) }.join('-')
        unique_posts = node['posts'].uniq { |p| p['url'] }
        {
          'name' => node['name'],
          'count' => node['count'],
          'path' => path,
          'slug' => slug,
          'posts' => unique_posts,
          'children' => normalize(node['children'], path)
        }
      end
    end

    def hidden?(post)
      post.data['hidden'] == true || post.data['hidden'].to_s == 'true'
    end

    def local_only?(post)
      post.data['local_only'] == true || post.data['local_only'].to_s == 'true'
    end
  end
end
