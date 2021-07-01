class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package

  after_commit :add_to_estuary_async, on: :create

  def add_to_estuary_async
    EstuaryArchiveWorker.perform_async(id)
  end

  def add_to_estuary
    return if pin_id.present?
    data = {
      name: "#{id}-#{url.split('/').last}",
      cid: cid,
      origins: ENV['IPFS_ADDRS'].split(',')
    }
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = 'https://api.estuary.tech/pinning/pins'
    response = Faraday.post(url, data.to_json, headers)
    if response.success?
      json = JSON.parse(response.body)
      update(pin_id: json["requestid"], pinned_at: Time.zone.now)
    end
  end
end
