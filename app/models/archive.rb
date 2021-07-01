class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package

  # after_commit :add_to_estuary_async, on: :create

  def add_to_estuary_async
    EstuaryArchiveWorker.perform_async(id)
  end

  def add_to_estuary
    return if pin_id.present?
    data = {
      name: "#{id}-#{url.split('/').last}",
      root: cid
    }
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = 'https://api.estuary.tech/content/add-ipfs'
    response = Faraday.post(url, data.to_json, headers)
    json = JSON.parse(response.body)
    update(pin_id: json["content"]["id"])
  end
end
