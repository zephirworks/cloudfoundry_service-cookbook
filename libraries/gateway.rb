class Chef
  module Mixin
    module CloudfoundryService
      module Gateway
        include Chef::Mixin::Language # for search

        def cfservicegw_supported_versions(service_name, role = "cloudfoundry_#{service_name}_node")
          if Chef::Config[:solo]
            return cfservice_get_versions(node, service_name)
          end

          nodes = cfservice_find_nodes_for_service(role)
          nodes.map do |svc_node|
            cfservice_get_versions(svc_node, service_name)
          end.flatten.compact.uniq
        end

        def cfservicegw_supported_versions_string(service_name, role = "cloudfoundry_#{service_name}_node")
          cfservicegw_supported_versions(service_name, role).map do |version|
            "\"#{version}\""
          end.join(", ")
        end

        def cfservice_find_nodes_for_service(role)
          if Chef::Config[:solo]
            Chef::Log.warn "cfservice_find_nodes_for_service is not meant for Chef Solo"
            return [node]
          end

          search(:node, "role:#{role} AND chef_environment:#{node.chef_environment}")
        end

      protected
        def cfservice_get_versions(svc_node, service_name)
          svc_node["cloudfoundry_#{service_name}_service"]['node']['versions'].keys
        end
      end
    end
  end
end

::Erubis::Context.send(:include, Chef::Mixin::CloudfoundryService::Gateway)
