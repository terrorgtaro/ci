# sourceのインストールディレクトリ

#PHP情報定義

install_path = "/usr/local"
apache_home = install_path + "/apache"
doc_root = "/vagrant/app"

install_info = {
  :apr => {
    :file_name  => "apr-1.5.2.tar.gz",
    :file_dir   => "apr-1.5.2",
    :configure  => "./configure --prefix=#{install_path}",
    :remote_uri => "http://www-us.apache.org/dist//apr/apr-1.5.2.tar.gz"
  },
  :aprutil => {
    :file_name  => "apr-util-1.5.4.tar.gz",
    :file_dir   => "apr-util-1.5.4",
    :configure  => "./configure --prefix=#{install_path} --with-apr=#{install_path}",
    :remote_uri => "http://www-eu.apache.org/dist//apr/apr-util-1.5.4.tar.gz"
  },
  :apache => {
    :file_name  => "httpd-2.4.20.tar.gz",
    :file_dir   => "httpd-2.4.20",
    :configure  => "./configure --prefix=#{apache_home} --with-apr=#{install_path} --with-apr-util=#{install_path} --enable-so --enable-ssl=shared --enable-proxy=shared",
    :remote_uri => "http://www-us.apache.org/dist//httpd/httpd-2.4.20.tar.gz"
  },
}

# PHPインストールに必要なモジュールをインストール
%w(openssl openssl-devel pcre-devel).each do |package_name|
  package "#{package_name}" do
    :install
  end
end

# install_info.each do |key, info|
#   remote_file "/tmp/#{info[:file_name]}" do
#      source "#{info[:remote_uri]}"
#   end
#
#   bash "install_#{key}" do
#
#     code <<-EOL
#       cd /tmp/
#       tar xvfz /tmp/#{info[:file_name]}
#       cd /tmp/#{info[:file_dir]}
#       #{info[:configure]} && make && make install
#     EOL
#
#   end
# end

#DocRootの設定
directory "#{doc_root}" do
  owner "vagrant"
  group "vagrant"
  recursive true
  mode 0755
  action :create
  not_if { File.exists? "#{doc_root}" }
end

# 設定ファイルを作成
template "#{apache_home}/conf/httpd.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "httpd.conf.erb"

    variables({
      :doc_root => doc_root
    })
end

# 自動起動設定ファイルを作成
template "/etc/init.d/httpd" do
    owner "root"
    group "root"
    mode "0755"
    source "httpd.init.erb"

    variables({
      :apache_home => apache_home
    })
end

# サービス追加
bash "add_service_httpd" do
  not_if "chkconfig --list | grep httpd"
  code <<-EOC
    chkconfig --add httpd
    chkconfig --level 35 httpd on
  EOC
end

# サービス起動
service "httpd" do
  action [ :enable, :start ]
end
