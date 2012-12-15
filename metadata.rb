name             "cloudfoundry_service"
maintainer       "Andrea Campi"
maintainer_email "andrea.campi@zephirworks.com"
license          "Apache 2.0"
description      "Base cookbook for cloudfoundry service cookbooks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ cloudfoundry logrotate rbenv }.each do |cb|
  depends cb
end
