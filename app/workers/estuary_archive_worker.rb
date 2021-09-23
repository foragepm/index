class EstuaryArchiveWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, lock: :until_executed

  def perform(archive_id)
    a = Archive.find_by_id(archive_id)
    return unless a
    a.pin_to_web3_storage
    a.pin
  end
end
