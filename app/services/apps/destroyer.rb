module Apps
  class Destroyer
    include Serviceable

    def call(app)
      return false if app.nil?

      AppDestroyProcessing.perform_async(app.id)
    end
  end
end
