class ArchiveVersionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(version_id)
    Version.find_by_id(version_id).try(:record_archive)
  end
end
