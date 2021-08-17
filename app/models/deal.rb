class Deal < ApplicationRecord

  after_commit :load_contents, on: :create

  scope :aggregate, -> { where('cid like ?', 'Qm%') }
  scope :with_files, -> { where('files_count > 0') }

  def self.sync_deals
    json = load_deals
    return unless json.present?
    json.each do |deal_json|
      next unless deal_json["aggregatedFiles"] > 1
      deal = Deal.find_or_initialize_by(deal_id: deal_json["id"])
      deal.cid = deal_json["cid"]
      deal.size = deal_json["size"]
      deal.files_count = deal_json["aggregatedFiles"]
      deal.save
    end
  end

  def self.load_deals
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }
    url = 'https://api.estuary.tech/content/deals?limit=100'
    response = Faraday.get(url, {}, headers)
    if response.success?
      Oj.load(response.body)
    end
  end

  def load_contents
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }

    url = "https://api.estuary.tech/content/aggregated/#{deal_id}"

    response = Faraday.get(url, {}, headers)
    if response.success?
      contents = Oj.load(response.body)
      contents.each do |content|
        a = Archive.find_by_cid(content['cid'])
        a.update_columns(deal_id: id) if a.present? && a.deal_id.blank?
      end
    end
  end

  def load_status
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ESTUARY_API_KEY']}"
    }

    url = "https://api.estuary.tech/content/status/#{deal_id}"

    response = Faraday.get(url, {}, headers)
    if response.success?
      json = Oj.load(response.body)
    end
  end
end
