# プロジェクトルート
bash "git_dir" do
  code <<-EOC
    mkdir /opt/lanikai
    chown vagrant:vagrant /opt/lanikai
  EOC
end
