class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package

  scope :not_pinned, -> { where(pin_id: nil) }
  scope :pinned, -> { where.not(pin_id: nil) }

  after_commit :pin_async, on: :create

  def pin_async
    EstuaryArchiveWorker.perform_async(id)
  end

  def pin
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
      update(pin_id: json["requestid"], pinned_at: Time.zone.now, pin_status: json["status"])
    end
  end

  def check_pin_status
    return unless pin_id.present?
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = "https://api.estuary.tech/pinning/pins/#{pin_id}"
    response = Faraday.get(url, {}, headers)
    if response.success?
      json = JSON.parse(response.body)
      update(pin_status: json["status"])
    end
  end
end
