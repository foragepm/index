class PackagesController < ApplicationController
  def import
    if params[:api_key] == ENV['IMPORT_API_KEY']
      ImportPackageWorker.perform_async(params[:platform], params[:name])
    end

    render :ok
  end
end
