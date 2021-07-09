class PackagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]

  def import
    if params[:api_key] == ENV['IMPORT_API_KEY']
      ImportPackageWorker.perform_async(params[:platform], params[:name])
    end

    head :ok
  end

  def recent
    @scope = Package.order('created_at DESC')
    @pagy, @packages = pagy(@scope)
  end

  def show
    @package = Package.find(params[:id])
    @version_scope = @package.versions.order('published_at DESC').includes(:archives)
    @pagy, @versions = pagy(@version_scope)
  end
end
