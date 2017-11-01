module Hooks
  class DatabaseSerializer < HookSerializer
    private

    def serialized_attributes
      %w(id namespace size type)
    end
  end
end
