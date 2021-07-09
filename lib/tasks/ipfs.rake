namespace :ipfs do
  task ping: :envirnoment do
    ipfs_host = ENV['IPFS_API'] || 'http://localhost:5001'
    Faraday.get("#{ipfs_host}/debug/metrics/prometheus")
  end
end
