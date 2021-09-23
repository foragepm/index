class ArchiveVersionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, lock: :until_executed

  def perform(version_id)
    a = Version.find_by_id(version_id).try(:record_archive)
    if a
      a.pin_to_web3_storage
      a.pin
    end
  end
end
