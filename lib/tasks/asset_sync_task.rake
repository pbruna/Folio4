require 'asset_sync'
# encoding: utf-8
namespace :assets do
  desc "Synchronize assets to S3"
  task :sync => :environment do
    AssetSync.sync
  end
end