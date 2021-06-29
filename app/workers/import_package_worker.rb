class ImportPackageWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, lock: :until_executed

  def perform(platform, name)
    "PackageManager::#{platform}".constantize.update(name)
  end
end
