Gem::Specification.new do |s|
  s.name    = "ysd_md_attachment"
  s.version = "0.1"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-07-27"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.summary = "Yurak Sisa Attachment model"
  
  s.add_runtime_dependency "data_mapper", "1.1.0"
  s.add_runtime_dependency "ysd_md_integration"   # External account service
 
  s.add_runtime_dependency "google_drive", "0.3.1"
  s.add_runtime_dependency "mime-types", "1.19"
  
end
