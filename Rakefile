task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/switch.zip autoload/ doc/switch.txt plugin/'
end
