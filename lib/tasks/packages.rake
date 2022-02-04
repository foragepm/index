namespace :packages do
  task backfill_npm: :environment do
    new_names = PackageManager::Npm.new_names.shuffle.first(100)
    new_names.each {|n| ImportPackageWorker.perform_async('Npm', n) }
  end

  task backfill_go: :environment do
    new_names = PackageManager::Go.new_names.shuffle.first(100)
    new_names.each {|n| ImportPackageWorker.perform_async('Go', n) }
  end
end
