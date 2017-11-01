module Namespaces
  class Upserter
    include Serviceable

    def call(namespace)
      return if system("kubectl get ns #{namespace}")

      system("kubectl create namespace #{namespace}")
    end
  end
end
