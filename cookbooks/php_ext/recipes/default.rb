
php_home = "/usr"
ext_info = {
  :xdebug => {
      :file_name  => 'xdebug-2.4.0.tgz',
      :file_dir   => 'xdebug-2.4.0',
      :configure  => './configure',
      :remote_uri => 'https://xdebug.org/files/xdebug-2.4.0.tgz',
      :ext_name   => 'xdebug.so',
      :add_line_sh   => "echo -n \"zend_extension=#{php_home}/lib/php/extensions/\" >> #{php_home}/lib/php.ini  && ls #{php_home}/lib/php/extensions | tr -d \"\n\" >> #{php_home}/lib/php.ini && echo -n \"/xdebug.so\" >> #{php_home}/lib/php.ini"
  },
}

ext_info.each do |key, info|
  remote_file "/tmp/#{info[:file_name]}" do
     source "#{info[:remote_uri]}"
  end

  bash "install_ext_#{key}" do

    code <<-EOL
      cd /tmp/
      tar xvfz /tmp/#{info[:file_name]}
      cd /tmp/#{info[:file_dir]}
      phpize
      #{info[:configure]} && make && make install
    EOL

  end


  bash "add_phpini_ext_#{key}" do
    not_if %!grep "#{info[:ext_name]}" /usr/lib/php.ini!

    code <<-EOC
      #{info[:add_line_sh]}
    EOC
  end

end
