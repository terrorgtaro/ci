yum_package "yum-fastestmirror" do
  action :install
end

execute "yum-update" do
  user "root"
  command "yum -y update"
  action :run
end

%w(libxml2 libxml2-devel openssl libcurl-devel autoconf git wget mailx).each do |package_name|
  package "#{package_name}" do
    :install
  end
end
