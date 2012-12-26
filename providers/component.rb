#
# Cookbook Name:: cloudfoundry_service
# Provider:: default
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
include Chef::Mixin::LanguageIncludeRecipe

def initialize(name, run_context=nil)
  super

  new_resource.service_name(new_resource.name) unless new_resource.service_name
  new_resource.config_dir(node['cloudfoundry']['config_dir']) unless new_resource.config_dir
  new_resource.data_dir(::File.join(node['cloudfoundry_service']['base_dir'], new_resource.service_name)) unless new_resource.data_dir
  new_resource.user(node['cloudfoundry']['user']) unless new_resource.user
  new_resource.group(node['cloudfoundry']['group']) unless new_resource.group
  new_resource.pid_dir(node['cloudfoundry']['pid_dir']) unless new_resource.pid_dir
  new_resource.log_dir(node['cloudfoundry']['log_dir']) unless new_resource.log_dir
  new_resource.lock_dir(node['cloudfoundry_service']['lock_dir']) unless new_resource.lock_dir
  new_resource.init_service_name("cloudfoundry-#{new_resource.name}") unless new_resource.init_service_name
  new_resource.base_path(node['cloudfoundry_service']['install_path']) unless new_resource.base_path
  new_resource.subdirectory(new_resource.service_name) unless new_resource.subdirectory

  # internal
  new_resource.ruby_version(node['cloudfoundry']['ruby_1_9_2_version']) unless new_resource.ruby_version
  new_resource.ruby_path(ruby_bin_path(new_resource.ruby_version)) unless new_resource.ruby_path

  service_resource = service new_resource.init_service_name do
    supports :status => true, :restart => true
    action :nothing
  end
  new_resource.service_resource(service_resource)
end

action :create do
  include_recipe "logrotate"
  include_recipe "cloudfoundry::default"

  installed = install_service if new_resource.install

  # no need to update, config files will if applicable
  create_config_directory

  config_file = ::File.join(new_resource.config_dir, "#{new_resource.name}.yml")
  pid_file = ::File.join(new_resource.pid_dir, "#{new_resource.name}.pid")
  log_file = ::File.join(new_resource.log_dir, "#{new_resource.name}.log")

  updated = [].tap do |updated|
    updated << create_config_file(config_file, pid_file, log_file)
    updated << add_to_init(config_file, pid_file, log_file)

    add_to_logrotate(pid_file, log_file) # does not mark as updated
  end.any?

  if new_resource.updated_by_last_action(installed || updated)
    new_resource.notifies(:restart, new_resource.service_resource)
  end
end

action :enable do
  new_resource.service_resource.run_action(:enable)
  new_resource.updated_by_last_action(new_resource.service_resource.updated_by_last_action?)
end

action :restart do
  new_resource.service_resource.run_action(:restart)
  new_resource.updated_by_last_action(new_resource.service_resource.updated_by_last_action?)
end

action :start do
  new_resource.service_resource.run_action(:start)
  new_resource.updated_by_last_action(new_resource.service_resource.updated_by_last_action?)
end

protected

def install_service
  r = cloudfoundry_service_install new_resource.service_name do
    base_path     new_resource.base_path
    subdirectory  new_resource.subdirectory
    user          new_resource.user
    action :nothing
  end
  r.run_action(:update)

  r.updated_by_last_action?
end

def create_config_directory
  d = directory new_resource.config_dir do
    user      new_resource.user
    recursive true
    action    :nothing
  end
  d.run_action(:create)

  d = directory new_resource.data_dir do
    user      new_resource.user
    recursive true
    action    :nothing
  end.run_action(:create)

  directory new_resource.lock_dir do
    user      new_resource.user
    recursive true
    action    :nothing
  end.run_action(:create)
end

def create_config_file(config_file, pid_file, log_file)
  t1 = template config_file do
    source  "#{new_resource.name}-config.yml.erb"
    owner   new_resource.user
    group   new_resource.group
    mode    0644
    variables(
      :pid_file       => pid_file,
      :log_file       => log_file
    )
    action  :nothing
  end
  t1.run_action(:create)

  t1.updated_by_last_action?
end

def add_to_init(config_file, pid_file, log_file)
  bin_file = ::File.join(new_resource.base_path, new_resource.service_name, "bin", new_resource.name)

  t2 = template "/etc/init/#{new_resource.init_service_name}.conf" do
    source   "upstart.conf.erb"
    cookbook "cloudfoundry"
    mode     0644
    variables(
      :component_name => new_resource.init_service_name,
      :user           => new_resource.user,
      :path           => new_resource.ruby_path,
      :bin_file       => bin_file,
      :config_file    => config_file,
      :pid_file       => pid_file,
      :extra_args     => new_resource.extra_args
    )
    action :nothing
  end
  t2.run_action(:create)

  l = link "/etc/init.d/#{new_resource.init_service_name}" do
    to      "/lib/init/upstart-job"
    action  :nothing
  end
  l.run_action(:create)

  t2.updated_by_last_action? || l.updated_by_last_action?
end

def add_to_logrotate(pid_file, log_file)
  user = new_resource.user

  logrotate_app new_resource.init_service_name do
    cookbook  "logrotate"
    path      log_file
    frequency "daily"
    rotate    30
    create    "644 #{user} #{user}"
  end
end
