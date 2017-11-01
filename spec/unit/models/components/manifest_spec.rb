require 'rails_helper'

RSpec.describe Component::Manifest, type: :model do
  subject do
    Component::Manifest.new(component: component, settings: settings)
  end

  let(:label_prefix) { Configurations.kubernetes.label_prefix }
  let(:transient_instances) { 1 }
  let(:type) { 'web' }
  let(:base_images_registry_url) { Configurations.docker.base_images_registry_url }

  let(:initial_delay) { 5 }

  let(:component) do
    instance_double(
      Component,
      name: 'some_component',
      environment: Environment.new(name: 'staging'),
      app_id: 'some_app',
      type: type,
      image_url: 'some_image',
      command: 'bundle exec [...]',
      scale: 10,
      node: double(
        :node,
        cpu: '3GHz',
        memory: '5000Mb',
        guaranteed_cpu: '2.8GHz',
        guaranteed_memory: '5000Mb'
      )
    )
  end

  let(:settings) { { 'SOME_SETTING' => 'SOME_VALUE' } }

  let(:rendered_manifest) do
    {
      apiVersion: 'extensions/v1beta1',
      kind: 'Deployment',
      metadata: {
        name: subject.name,
        labels: {
          "#{label_prefix}/app" => subject.app_id,
          "#{label_prefix}/environment" => subject.environment.name,
          "#{label_prefix}/component" => subject.type
        }.with_indifferent_access
      },
      spec: {
        replicas: component.scale,
        strategy: {
          rollingUpdate: {
            maxSurge: transient_instances,
            maxUnavailable: transient_instances
          }
        },
        template: {
          metadata: {
            labels: {
              "#{label_prefix}/app" => subject.app_id,
              "#{label_prefix}/environment" => subject.environment.name,
              "#{label_prefix}/component" => subject.type
            }.with_indifferent_access
          },
          spec: {
            containers: container_data
          }.with_indifferent_access
        }
      }.with_indifferent_access
    }.with_indifferent_access
  end

  let(:default_app_container_data) do
    {
      name: subject.name,
      image: subject.image_url,
      imagePullPolicy: 'Always',
      env: parsed_settings,
      command: ['bash', '-c', subject.command],
      resources: {
        limits: {
          cpu: subject.node.cpu,
          memory: subject.node.memory
        },
        requests: {
          cpu: subject.node.guaranteed_cpu,
          memory: subject.node.memory
        }
      }.with_indifferent_access,
      ports: [{ containerPort: 8090 }],
      lifecycle: {
        preStop: {
          exec: {
            command: ['bash', '-c', 'touch /terminate; sleep 20']
          }
        }
      }.with_indifferent_access,
      readinessProbe: {
        exec: { command: ['bash', '-c', '! test -f /terminate'] },
        failureThreshold: 1,
        initialDelaySeconds: initial_delay,
        periodSeconds: 10,
        successThreshold: 1,
        timeoutSeconds: 10
      }.with_indifferent_access
    }
  end

  let(:default_web_container_data) do
    {
      name: "#{subject.name}-nginx",
      image: "#{base_images_registry_url}/nginx-frontend:latest",
      imagePullPolicy: 'Always',
      env: [{ name: 'FRONTEND_PORT', value: '8080' }, { name: 'BACKEND_PORT', value: '8090' }],
      command: ['bash', '-c', '/run_proxy.sh'],
      resources: {
        limits: {
          cpu: '4',
          memory: '128Mi'
        },
        requests: {
          cpu: '256m',
          memory: '128Mi'
        }
      }.with_indifferent_access,
      ports: [{ containerPort: 8080 }],
      lifecycle: {
        preStop: {
          exec: {
            command: ['bash', '-c', 'touch /terminate; sleep 20']
          }
        }
      }.with_indifferent_access,
      readinessProbe: {
        exec: { command: ['bash', '-c', '! test -f /terminate'] },
        failureThreshold: 1,
        initialDelaySeconds: initial_delay,
        periodSeconds: 10,
        successThreshold: 1,
        timeoutSeconds: 10
      }.with_indifferent_access
    }
  end

  let(:container_data) { [default_app_container_data, default_web_container_data] }

  let(:parsed_settings) do
    [
      { name: 'SOME_SETTING', value: 'SOME_VALUE' }.with_indifferent_access,
      { name: '_JAVA_OPTIONS', value: '-Xmx1280m -Xms1280m' }.with_indifferent_access,
      { name: '_BUSBAR_BUILD_TIME', value: subject.timestamp.to_s }.with_indifferent_access,
      { name: 'PORT', value: '8090' }.with_indifferent_access
    ]
  end

  describe '#render' do
    it 'renders the manifest as a hash' do
      expect(subject.render).to eq(rendered_manifest)
    end

    context 'when it has a PORT key on settings' do
      let(:container_data) do
        [default_app_container_data.merge(
          ports: [{ containerPort: 9010 }]),
         default_web_container_data.merge(
           ports: [{ containerPort: 9000 }],
           env: [{ name: 'FRONTEND_PORT', value: '9000' },
                 { name: 'BACKEND_PORT', value: '9010' }])]
      end

      let(:settings) do
        {
          'SOME_SETTING' => 'SOME_VALUE',
          'PORT' => 9000
        }
      end

      let(:parsed_settings) do
        [
          { name: 'SOME_SETTING', value: 'SOME_VALUE' }.with_indifferent_access,
          { name: '_JAVA_OPTIONS', value: '-Xmx1280m -Xms1280m' }.with_indifferent_access,
          { name: '_BUSBAR_BUILD_TIME', value: subject.timestamp.to_s }.with_indifferent_access,
          { name: 'PORT', value: '9010' }.with_indifferent_access
        ]
      end

      it 'renders the manifest with the PORT info' do
        expect(subject.render).to eq(rendered_manifest)
      end
    end

    context 'when there is an APPS_NODE_SELECTOR config set on busbar' do
      before :context do
        Configurations.apps.node_selector = 'c4.large'
      end

      after :context do
        Configurations.apps.node_selector = ENV.fetch('APPS_NODE_SELECTOR', nil)
      end

      let(:rendered_manifest) do
        {
          apiVersion: 'extensions/v1beta1',
          kind: 'Deployment',
          metadata: {
            name: subject.name,
            labels: {
              "#{label_prefix}/app" => subject.app_id,
              "#{label_prefix}/environment" => subject.environment.name,
              "#{label_prefix}/component" => subject.type
            }.with_indifferent_access
          },
          spec: {
            replicas: component.scale,
            strategy: {
              rollingUpdate: {
                maxSurge: transient_instances,
                maxUnavailable: transient_instances
              }
            },
            template: {
              metadata: {
                labels: {
                  "#{label_prefix}/app" => subject.app_id,
                  "#{label_prefix}/environment" => subject.environment.name,
                  "#{label_prefix}/component" => subject.type
                }.with_indifferent_access
              },
              spec: {
                containers: container_data,
                nodeSelector: { "beta.kubernetes.io/instance-type": \
                                Configurations.apps.node_selector \
              } }.with_indifferent_access
            }
          }.with_indifferent_access
        }.with_indifferent_access
      end

      it 'renders the manifest with the APPS_NODE_SELECTOR setting' do
        expect(subject.render).to eq(rendered_manifest)
      end
    end

    context 'when there is an _INITIAL_DELAY config set' do
      let(:settings) do
        {
          'SOME_SETTING'   => 'SOME_VALUE',
          '_INITIAL_DELAY' => '15'
        }
      end

      let(:initial_delay) { 15 }

      let(:parsed_settings) do
        [
          { name: 'SOME_SETTING', value: 'SOME_VALUE' }.with_indifferent_access,
          { name: '_INITIAL_DELAY', value: '15' }.with_indifferent_access,
          { name: '_JAVA_OPTIONS', value: '-Xmx1280m -Xms1280m' }.with_indifferent_access,
          { name: '_BUSBAR_BUILD_TIME', value: subject.timestamp.to_s }.with_indifferent_access,
          { name: 'PORT', value: '8090' }.with_indifferent_access
        ]
      end

      it 'renders the manifest with the _INITIAL_DELAY setting' do
        expect(subject.render).to eq(rendered_manifest)
      end
    end

    context 'when there is UNAVAILABLE_PERCENTAGE config set' do
      before do
        allow(Configurations).to receive_message_chain(:manifest, :unavailable_percentage)
          .and_return(50)
      end

      let(:transient_instances) { 5 }

      it 'uses it to calculate the maxSurge and maxUnavailable values' do
        expect(subject.render).to eq(rendered_manifest)
      end

      context 'when the percentage of the calculation is below 10' do
        before do
          allow(Configurations).to receive_message_chain(:manifest, :unavailable_percentage)
            .and_return(1)
        end

        let(:transient_instances) { 1 }

        it 'uses 1 as maxSurge and maxUnavailable values' do
          expect(subject.render).to eq(rendered_manifest)
        end
      end
    end

    context 'when a non-web component is rendered' do
      let(:type) { 'worker' }

      let(:container_data) do
        [default_app_container_data.merge(ports: [{ containerPort: 8080 }])]
      end

      let(:parsed_settings) do
        [
          { name: 'SOME_SETTING', value: 'SOME_VALUE' }.with_indifferent_access,
          { name: '_JAVA_OPTIONS', value: '-Xmx1280m -Xms1280m' }.with_indifferent_access,
          { name: '_BUSBAR_BUILD_TIME', value: subject.timestamp.to_s }.with_indifferent_access,
          { name: 'PORT', value: '8080' }.with_indifferent_access
        ]
      end

      it 'renders the manifest without the nginx container' do
        expect(subject.render).to eq(rendered_manifest)
      end
    end
  end
end
