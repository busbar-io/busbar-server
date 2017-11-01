class DatabasesController < ApplicationController
  before_action :load_database, only: %i(show destroy)

  def index
    @databases = Database.all

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def show
    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def create
    @database = DatabaseService.create(database_params)

    respond_to do |format|
      if @database.persisted?
        format.json { render status: :created }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      DatabaseService.destroy(@database)

      format.json { head :no_content }
    end
  end

  private

  def database_params
    params.permit(:id, :type, :namespace)
  end

  def load_database
    @database = Database.find(params[:id])
  end
end
