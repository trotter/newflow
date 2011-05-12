PKG_VERSION = '1.0.1'
PKG_FILES   = Dir['lib/**/*.rb',
                  'spec/**/*.rb']

$spec = Gem::Specification.new do |s|
  s.name = 'newflow'
  s.version = PKG_VERSION
  s.summary = "Add workflows (state transitions) to objects."
  s.description = <<EOS
Newflow provides a way to add workflows to existing objects. It uses
a simple dsl to add guards and triggers to states and their transitions.
EOS
  
  s.files = PKG_FILES.to_a

  s.has_rdoc = false
  s.authors  = ["Trotter Cashion", "Kyle Burton", "Aaron Feng"]
  s.email    = "cashion@gmail.com"
  s.homepage = "http://trottercashion.com"
end

