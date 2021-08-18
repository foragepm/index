class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package
  belongs_to :deal, optional: true

  scope :not_pinned, -> { where(pin_id: nil) }
  scope :pinned, -> { where.not(pin_id: nil) }

  scope :not_yanked, -> { joins(:version).where('versions.yanked = ?', false) }

  after_commit :pin_async, on: :create
  after_commit :pin_to_web3_storage_async, on: :create

  def pin_async
    EstuaryArchiveWorker.perform_async(id)
  end

  def pin_to_web3_storage_async
    return if web3
    Web3StorageWorker.perform_async(id)
  end

  def filename
    url.split('/').last
  end

  def pin_to_web3_storage
    return if web3
    return if size > 30.megabyte
    return if url.blank?
    # url = "#{ENV['TRANSPORTER_URL']}/?cid=#{cid}&filename=#{id}-#{filename}"
    transport_url = "#{ENV['TRANSPORTER_URL']}/upload?filename=#{id}-#{filename}&url=#{self.url}"
    response = Faraday.get(transport_url)
    if response.success?
      update_columns(web3: true)
    else
      check_availability
    end
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

    conn = Faraday.new do |conn|
      conn.options.timeout = 10
    end

    begin
      response = conn.post(url, data.to_json, headers)
      if response.success?
        json = Oj.load(response.body)
        update_columns(pin_id: json["requestid"], pinned_at: Time.zone.now, pin_status: json["status"], updated_at: Time.zone.now)
      end
    rescue Faraday::TimeoutError
      # timeout
    end
  end

  def check_pin_status
    return unless pin_id.present?
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = "https://api.estuary.tech/pinning/pins/#{pin_id}"

    conn = Faraday.new do |conn|
      conn.options.timeout = 10
    end

    begin
      response = conn.get(url, {}, headers)
      if response.success?
        json = Oj.load(response.body)
        update_columns(pin_status: json["status"], updated_at: Time.zone.now)
      end
    rescue Faraday::TimeoutError
      # timeout
    end
  end

  def remove_pin
    return unless pin_id.present?
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = "https://api.estuary.tech/pinning/pins/#{pin_id}"

    conn = Faraday.new do |conn|
      conn.options.timeout = 10
    end

    begin
      response = conn.delete(url, {}, headers)
      response.success?
    rescue Faraday::TimeoutError
      # timeout
    end
  end

  def check_availability
    conn = Faraday.new do |conn|
      conn.options.timeout = 10
    end

    begin
      response = conn.head(url)
      if response.status == 404
        version.update_columns(yanked: true)
        # remove_pin # disabled due to estuary timeouts
        self.destroy
      end
    rescue Faraday::TimeoutError
      # timeout
    end
  end

  def self.check_pin_status
    # TODO pagination
    first = Archive.where(pin_status: 'queued').order('pinned_at ASC').first
    after = first.try(:pinned_at)
    batch_update_pin_status(after) if after
  end

  def self.batch_update_pin_status(after)
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = "https://api.estuary.tech/pinning/pins?limit=1000&after=#{after.to_s(:iso8601)}"
    response = Faraday.get(url, {}, headers)
    if response.success?
      json = Oj.load(response.body)

      ids = json['results'].map{|r| r['requestid'] }
      archives = Archive.where(pin_id: ids)

      json['results'].each do |res|
        archive = archives.find{|a| a.pin_id == res['requestid'].to_i }
        next if archive.nil?
        archive.update_columns(pin_status: res['status'], updated_at: Time.now) if archive.pin_status != res['status']
      end
    end
  end

  def self.retry_failed_pins
    Archive.where(pin_status: 'failed').not_yanked.find_each do |a|
      unless a.check_availability
        a.pin_id = nil
        a.pin
      end
    end
  end
end
