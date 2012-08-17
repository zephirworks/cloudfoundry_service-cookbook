Description
===========

A Chef cookbook that provides basic functionality for writing cookbooks that manage [CloudFoundry](http://www.cloudfoundry.org/) services.

Requirements
============

Cookbooks
---------

* cloudfoundry

Platform
--------

* Ubuntu

Tested on:

* Ubuntu 11.10

Attributes
==========

This cookbooks defines common attributes that are used by its own recipes and resources, as well as by the actual services cookbooks.

The following attributes are user-configurable:

* `node['cloudfoundry_service']['install_path']` - The directory where sources for each service will be installed. Defaults to "/srv/vcap-srv"
* `node['cloudfoundry_service']['repo']` - The URL to a git repository containing the sources for all the services. If you wish to make changes to the source code, you can fork this repository and change this attribute to point to your own fork. Defaults to "https://github.com/cloudfoundry/vcap-services.git"
* `node['cloudfoundry_service']['reference']` - A reference to a commit (the SHA1 or a branch name) to deploy. Defaults to "ac31866f8568593d8499ad07c5a74ae7ed527aa4"

Resources/Providers
===================

cloudfoundry\_service\_install
------------------------------

Manages the installation of a CloudFoundry service.

At the time of this writing, services are distributed only in source form as part of the
`vcap-services` git repository; this resource checks out the git repository only once regardless
of the number of services that are installed.
When the content of the repository changes, it will automatically perform any task that is
required to updated all the services running on a node. In particular, it will restart every
service that is installed from that repository, since there is no way of detecting changes in a
single service.

Warning: the current version of this resource strongly assumes this particular layout; as a
consequence, installing different services to unrelated directories is not supported at this time.

Implementation details:

* this resource runs Bundler in the service directory if and only if the git chackout was updated.
In other words, if you make other changes (deinstall a gem, or make manual changes) you need to
run `bundle` manually.

# Actions:

* `:update` - updates the installation of the given service.

# Attribute parameters

- `name`: name attribute. The name of the service you wish to install. This will be used to derive the default value for other attribute;
- `base_path`: path to a directory that will contain the installation of all the services; it will be created if it does not exist. Defaults to `node['cloudfoundry_service']['install_path']`;
- `subdirectory`: name of a subdirectory of `base_path` that will contain the installation of this services; it will be created if it does not exist. Defaults to `name`;
- `path`: path to a directory that will contain the installation of this services; it will be created if it does not exist. Note: at this time it *must* be a subdirectory of `base_path`; Defaults to `#{base_path}/#{subdirectory}`;
- `user`: the user that will own the installed files. Defaults to `node['cloudfoundry']['user']`;
- `repository`: the URL to a git repository containing the sources for all the services. Defaults to `node['cloudfoundry_service']['repo']`;
- `reference`: a reference to a commit (the SHA1 or a branch name) to deploy. Defaults to `node['cloudfoundry_service']['reference']`;
- `enable_submodules`: if true, any submodules for the repository will by updated as well. This must be true when using the default repository; only change if you know what you are doing. Defaults to `true`;
- `depth`: if not nil, it will limit the depth of the git checkout to the given value; this may speed up the deployment. Defaults to `10`;
- `ruby_version`: the version of Ruby that will be used to run Bundler. Defaults to `node['cloudfoundry']['ruby_1_9_2_version']`;
- `ruby_path`: the path to a Ruby interpreter that will be used to run Bundler. Defaults to the `rbenv` installation of Ruby version `node['cloudfoundry']['ruby_1_9_2_version']`.

Usage
=====

