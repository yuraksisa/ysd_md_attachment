Gem::Specification.new do |s|
  s.name    = "ysd_md_attachment"
  s.version = "0.2.3"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-07-27"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.summary = "Yurak Sisa Attachments model"
  s.homepage = "http://github.com/yuraksisa/ysd_md_attachment"
    
  s.add_runtime_dependency "data_mapper", "1.2.0"
  s.add_runtime_dependency "google_drive", "0.3.1"
  s.add_runtime_dependency "mime-types", "1.19"
  
  s.add_runtime_dependency "ysd_md_integration"   # External account service
  s.add_runtime_dependency "ysd-persistence"      # Persistence system
  s.add_runtime_dependency "ysd_core_plugins"     # Aspects
  s.add_runtime_dependency "ysd_md_configuration" # Configuration

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "dm-sqlite-adapter" # Model testing using sqlite
      
end
