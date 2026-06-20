#!/usr/bin/env ruby
#
# Check for changed posts

Jekyll::Hooks.register :posts, :post_init do |post|
  # Skip git-based lastmod lookup when source is not a git checkout.
  next unless system('git rev-parse --is-inside-work-tree > /dev/null 2>&1')

  commit_num = `git rev-list --count HEAD "#{post.path}" 2>/dev/null`

  if commit_num.to_i > 1
    lastmod_date = `git log -1 --pretty="%ad" --date=iso "#{post.path}" 2>/dev/null`
    post.data['last_modified_at'] = lastmod_date
  end

end
