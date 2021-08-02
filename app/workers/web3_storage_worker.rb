class Web3StorageWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, lock: :until_executed

  def perform(archive_id)
    Archive.find_by_id(archive_id).try(:pin_to_web3_storage)
  end
end
