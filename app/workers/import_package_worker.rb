class ImportPackageWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform(platform, name)
    "PackageManager::#{platform}".constantize.update(name)
  end
end
