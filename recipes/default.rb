#
# Cookbook Name:: database_yml
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#
#
# Cookbook Name: database
# Recipe: default
#
# Description:
# Configure application servers to use mysql2 adapter for the database.yml config.
# All parameters except the adapter are pulled from the EY node JSON element. See
# http://docs.engineyard.com/use-deploy-hooks-with-engine-yard-cloud.html for an
# example of the node JSON object. This object is also used for by deploy hooks
# at Engine Yard.
#
# This file should be in .../cookbooks/database/recipes/default.rb
#
#
# Q: Why do we need this custom recipe?
#
# A: We needed to generate our own database.yml file because Engine Yard's default
# database.yml file generator always generates a config file that uses the mysql
# adapter for Rails 2 apps and always uses the mysql2 adapter for Rails 3 apps.
#
# In our case we needed to use the mysql2 adapter with our existing Rails 2 app.
#
# Apps using a replicated DB setup on EY may also need a custom Chef recipe to
# generate a database.yml
#
 
# Should add this check in the future
# if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])

# for each application
Array(node["rackbox"]["apps"]["passenger"]).each_with_index do |app, index|

# create new database.yml
template "#{::File.join(node["appbox"]["apps_dir"], app["appname"], 'shared/config/database.yml')}" do
  source 'database.yml.erb'
  owner node["appbox"]["apps_user"]
  group node["appbox"]["apps_user"]
  mode 0644
  variables({
    :environment => "production",
    :adapter => 'mysql2',
    :database => node["databox"]["databases"]["mysql"].first["database_name"],
    :username => node["databox"]["databases"]["mysql"].first["username"],
    :password => node["databox"]["databases"]["mysql"].first["password"],
    :host => 'localhost'
  })
end
end



template "#{applications_root}/#{app}/shared/config/database.yml" do
  owner deploy_user
  group deploy_user
  mode 0600
  source "app_database.yml.erb"
end