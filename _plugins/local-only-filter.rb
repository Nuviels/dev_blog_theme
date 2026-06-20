#!/usr/bin/env ruby
#
# Exclude `local_only: true` content from non-development builds.

module Jekyll
  class LocalOnlyFilter < Generator
    safe true
    priority :highest

    def generate(site)
      return if Jekyll.env == 'development'

      site.pages.each do |page|
        mark_unpublished(page)
      end

      site.collections.each_value do |collection|
        collection.docs.each do |doc|
          mark_unpublished(doc)
        end
      end
    end

    private

    def mark_unpublished(item)
      return unless truthy?(item.data['local_only'])

      item.data['published'] = false
    end

    def truthy?(value)
      value == true || value.to_s == 'true'
    end
  end
end
