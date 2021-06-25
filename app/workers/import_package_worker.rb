class PackageManagerDownloadWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform(platform, name)
    "PackageManager::#{class_name}".constantize.update(name)
  end
end
