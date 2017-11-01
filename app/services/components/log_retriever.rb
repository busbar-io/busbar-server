module Components
  class LogRetriever
    include Serviceable

    def call(component, size = nil)
      @component = component
      @size = size || Configurations.log.components.size

      ComponentLog.new(content: logs)
    end

    private

    def logs
      query_result.reverse.map { |log_entry| log_entry['_source']['log'] }.join
    end

    def query_result
      ElasticSearchClient.search(query)['hits']['hits']
    end

    def query
      {
        body: {
          query: {
            bool: {
              must: criteria
            }
          },
          _source: ['log'],
          size: @size,
          sort: [
            {
              '@timestamp': {
                'order': 'desc'
              }
            }
          ]
        }
      }
    end

    def criteria
      [
        {
          match: { 'kubernetes.labels.busbar_io/app': @component.app_id }
        },
        {
          match: { 'kubernetes.labels.busbar_io/component': @component.type }
        },
        {
          match: { 'kubernetes.labels.busbar_io/environment': @component.environment_name }
        }
      ]
    end
  end
end
