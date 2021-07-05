class CheckPinStatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, lock: :until_executed

  def perform(archive_id)
    Archive.find_by_id(archive_id).try(:check_pin_status)
  end
end
