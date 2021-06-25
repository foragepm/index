class PackagesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:import]

  def import
    if params[:api_key] == ENV['IMPORT_API_KEY']
      ImportPackageWorker.perform_async(params[:platform], params[:name])
    end

    head :ok
  end
end
