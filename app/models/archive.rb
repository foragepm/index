class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package
  belongs_to :deal, optional: true

  scope :not_pinned, -> { where(pin_id: nil) }
  scope :pinned, -> { where.not(pin_id: nil) }

  after_commit :pin_async, on: :create

  def pin_async
    EstuaryArchiveWorker.perform_async(id)
  end

  def filename
    url.split('/').last
  end

  def pin
    return if pin_id.present?
    data = {
      name: "#{id}-#{filename}",
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
      json = Oj.load(response.body)
      update_columns(pin_id: json["requestid"], pinned_at: Time.zone.now, pin_status: json["status"], updated_at: Time.zone.now)
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
      json = Oj.load(response.body)
      update_columns(pin_status: json["status"], updated_at: Time.zone.now)
    end
  end

  def remove_pin
    return unless pin_id.present?
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = "https://api.estuary.tech/pinning/pins/#{pin_id}"
    response = Faraday.delete(url, {}, headers)
    response.success?
  end

  def check_availability
    response = Faraday.head(url)
    if response.status == 404
      version.update_columns(yanked: true)
      remove_pin
      self.destroy
    end
  end
end
