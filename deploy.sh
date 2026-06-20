#!/usr/bin/env bash
set -e

cd /home/ubuntu/blog
bundle exec jekyll build
sudo rsync -av --delete /home/ubuntu/blog/_site/ /var/www/blog/
sudo nginx -t
sudo systemctl reload nginx

echo "Deploy complete"
