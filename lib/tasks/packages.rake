namespace :packages do
  task backfill_npm: :environment do
    new_names = PackageManager::Npm.new_names.first(100)
    new_names.each {|n| ImportPackageWorker.perform_async('Npm', n) }
  end
end
