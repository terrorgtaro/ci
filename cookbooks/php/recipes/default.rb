# sourceのインストールディレクトリ

#PHP情報定義
install_path = "/usr"
info = {
  :file_name  => "php-7.0.6.tar.gz",
  :file_dir   => "php-7.0.6",
  :configure  => "./configure --prefix=#{install_path} --with-apxs2 --with-pdo-mysql=mysqlnd --with-mcrypt=/usr/lib --enable-mbstring  --enable-ftp --with-openssl --with-curl --with-ftp",
  :remote_uri => "http://jp2.php.net/get/php-7.0.6.tar.gz/from/this/mirror"
}

# PHPインストールに必要なモジュールをインストール
%w(libmcrypt libmcrypt-devel openssl openssl-devel httpd-devel).each do |package_name|
  package "#{package_name}" do
    :install
  end
end


# ダウンロード
remote_file "/tmp/#{info[:file_name]}" do
   source "#{info[:remote_uri]}"
end

# インストール
bash 'install' do

  code <<-EOL
    cd /tmp/
    tar xvfz /tmp/#{info[:file_name]}
    cd /tmp/#{info[:file_dir]}
    #{info[:configure]} && make && make install
  EOL

end

#php.iniを移動
bash 'move_phpini' do

  code <<-EOL
    mv /tmp/#{info[:file_dir]}/php.ini-development /usr/lib/php.ini
  EOL

end

bash 'composer' do
  code <<-EOL
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar #{install_path}/bin/composer
  EOL
end
