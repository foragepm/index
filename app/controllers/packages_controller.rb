class PackagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import, :lookup]

  def import
    if params[:api_key] == ENV['IMPORT_API_KEY']
      ImportPackageWorker.perform_async(params[:platform], params[:name])
    end

    head :ok
  end

  def lookup
    keys = (params[:keys] || '').split(',').first(1000)
    archives = Archive.where(key: keys).select('key,cid')
    results = {}
    archives.each do |a|
      results[a.key] = a.cid
    end

    missing_keys = results.select{|k,v| v.nil?}.keys.uniq
    puts "Enqueing backfill for #{missing_keys.length} keys"
    missing_keys.each do |k|
      parts = k.split(':')
      ImportPackageWorker.perform_async(parts[0], parts[1], 100)
    end

    render json: results
  end

  def recent
    @scope = Package.with_versions.order('created_at DESC')
    @pagy, @packages = pagy_countless(@scope)
  end

  def show
    @package = Package.find(params[:id])
    @version_scope = @package.versions.order('published_at DESC NULLS LAST, created_at DESC').includes(archives: :deal)
    @pagy, @versions = pagy_countless(@version_scope)
  end
end
