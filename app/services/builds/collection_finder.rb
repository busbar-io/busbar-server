module Builds
  class CollectionFinder
    include Serviceable

    def call(environment)
      environment.builds.desc(:updated_at).limit(10)
    end
  end
end
