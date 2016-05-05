bash "yum_init" do
  code <<-EOC
    yum remove mysql*
    yum install -y http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
    yum-config-manager --disable mysql56-community
    yum-config-manager --enable mysql55-community
  EOC
end

%w(mysql mysql-server mysql-devel).each do |package_name|
  package "#{package_name}" do
    :install
  end
end

bash "add_mysql_service" do
  code <<-EOL
    chkconfig --add mysqld
  EOL
end

template "/etc/my.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "my.conf.erb"
end

service "mysqld" do
  action [:start, :enable]
end


root_password = node['mysql']['root_db_password']
bash "mysql_secure_installation" do
  code <<-EOC
    mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -e "DROP DATABASE test;"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{root_password}');" -D mysql
    mysql -u root --password=\"#{root_password}\" -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{root_password}');" -D mysql
    mysql -u root --password=\"#{root_password}\" -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('#{root_password}');" -D mysqlow 
    mysql -u root --password=\"#{root_password}\" -e "FLUSH PRIVILEGES;"
  EOC
  only_if "mysql -u root -e 'show databases'"
end


execute "mysql-create-user" do
    command "/usr/bin/mysql -u root --password=\"\"  < /tmp/db.sql"
    action :nothing
end


template "/tmp/db.sql" do
    owner "root"
    group "root"
    mode "0600"
    variables(
        :user     => node['mysql']['system_db_user'],
        :password => node['mysql']['system_db_password'],
        :database => node['mysql']['system_db_database']
    )
    notifies :run, "execute[mysql-create-user]", :immediately
end