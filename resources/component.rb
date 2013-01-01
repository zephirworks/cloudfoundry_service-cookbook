#
# Cookbook Name:: cloudfoundry_service
# Resource:: component
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

actions :create, :enable, :restart, :start
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :service_name, :kind_of => [String, NilClass], :required => true
attribute :install, :kind_of => [TrueClass, FalseClass, NilClass], :default => true
attribute :config_dir, :kind_of => [String, NilClass], :default => nil
attribute :data_dir, :kind_of => [String, NilClass], :default => nil
attribute :user, :kind_of => [String, NilClass], :default => nil
attribute :group, :kind_of => [String, NilClass], :default => nil
attribute :pid_dir, :kind_of => [String, NilClass], :default => nil
attribute :log_dir, :kind_of => [String, NilClass], :default => nil
attribute :lock_dir, :kind_of => [String, NilClass], :default => nil
attribute :init_service_name, :kind_of => [String, NilClass], :default => nil
attribute :base_path, :kind_of => [String, NilClass], :default => nil
attribute :subdirectory, :kind_of => [String, NilClass], :default => nil
attribute :extra_args, :kind_of => [String, NilClass], :default => nil

# internal
attribute :ruby_version, :kind_of => [String, NilClass], :default => nil
attribute :ruby_path, :kind_of => [String, NilClass], :default => nil
attribute :service_resource
