%w(httpd).each do |package_name|
  package "#{package_name}" do
    :install
  end
end

bash "add_httpd_service" do
  code <<-EOL
    chkconfig --add httpd
  EOL
end

template "/etc/httpd/conf/httpd.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "httpd.conf.erb"
    variables({
      :doc_root => node['apache']['doc_root']
    })
end

#DocRootの設定
directory "#{node['apache']['doc_root']}" do
  owner "vagrant"
  group "vagrant"
  recursive true
  mode 0755
  action :create
  not_if { File.exists? "#{node['apache']['doc_root']}" }
end

service "httpd" do
  action [ :enable, :start ]
end
