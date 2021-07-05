class EstuaryArchiveWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, lock: :until_executed

  def perform(archive_id)
    Archive.find_by_id(archive_id).try(:pin)
  end
end
