#
# Cookbook Name:: cloudfoundry_service
# Definitions:: default
#
# Copyright 2012-2013, ZephirWorks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :service_rbenv do
  default_version = params[:default_version] || node['cloudfoundry_service']['ruby_version']
  namespace = params[:namespace]
  component = params[:component]

  node.default[namespace][component]['ruby_version'] = default_version

  ruby_ver = node[namespace][component]['ruby_version']
  ruby_path = ruby_bin_path(ruby_ver)

  include_recipe "rbenv::default"
  include_recipe "rbenv::ruby_build"

  rbenv_ruby ruby_ver
end
