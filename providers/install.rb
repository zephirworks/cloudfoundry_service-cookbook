#
# Cookbook Name:: cloudfoundry_service
# Provider:: install
#
# Copyright 2012, ZephirWorks
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

include Chef::Mixin::CloudfoundryCommon

def initialize(name, run_context=nil)
  super

  new_resource.base_path(node['cloudfoundry_service']['install_path']) unless new_resource.base_path
  new_resource.subdirectory(new_resource.name) unless new_resource.subdirectory
  new_resource.path(::File.join(new_resource.base_path, new_resource.subdirectory)) unless new_resource.path
  new_resource.user(node['cloudfoundry']['user']) unless new_resource.user
  new_resource.repository(node['cloudfoundry_service']['repo']) unless new_resource.repository
  new_resource.reference(node['cloudfoundry_service']['reference']) unless new_resource.reference
  new_resource.ruby_version(node['cloudfoundry']['ruby_1_9_2_version']) unless new_resource.ruby_version
  new_resource.ruby_path(ruby_bin_path(new_resource.ruby_version))

  @updated = false
end

action :update do
  Chef::Log.debug("Running :update for #{new_resource}")

  create_target_directory
  install_bundler

  Chef::Log.debug("Running :update for #{new_resource}: @updated was #{@updated}")
  # Make sure that once we set updated=true it never goes false in the same run
  @updated ||= update_git_repository_if_needed
  Chef::Log.debug("Running :update for #{new_resource}: @updated now #{@updated}")

  if @updated
    run_bundler
  end

  Chef::Log.debug("Running :update for #{new_resource}: returning #{@updated}")
  new_resource.updated_by_last_action(@updated)
end

protected

def create_target_directory
  Chef::Log.debug("Running create_target_directory for #{new_resource}")

  d = directory new_resource.base_path do
    user new_resource.user
    recursive true
    action :nothing
  end
  d.run_action(:create)
end

def install_bundler
  Chef::Log.debug("Running install_bundler for #{new_resource}")

  gr = rbenv_gem "bundler" do
    ruby_version new_resource.ruby_version
    action :nothing
  end
  gr.run_action(:install)
end

def update_git_repository_if_needed
  Chef::Log.debug("Running update_git_repository_if_needed for #{new_resource}")

  r = git new_resource.base_path do
    repository        new_resource.repository
    reference         new_resource.reference
    user              new_resource.user
    enable_submodules new_resource.enable_submodules
    depth             new_resource.depth
    action :nothing
  end
  r.run_action(:sync)

  Chef::Log.debug("Running update_git_repository_if_needed for #{new_resource}: returning #{r.updated_by_last_action?}")
  r.updated_by_last_action?
end

def run_bundler
  Chef::Log.debug("Running run_bundler for #{new_resource}")

  br = bash "install gems in #{new_resource.path}" do
    user new_resource.user
    cwd  new_resource.path
    code "#{::File.join(new_resource.ruby_path, "bundle")} install --without=test --standalone"
    action :nothing
  end
  br.run_action(:run)
end
