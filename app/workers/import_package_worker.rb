class ImportPackageWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, lock: :until_executed

  def perform(platform, name, version_limit = 20)
    "PackageManager::#{platform.capitalize}".constantize.update(name, version_limit)
  end
end
