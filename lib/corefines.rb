require 'corefines/version'
require 'corefines/support/alias_submodules'

unless [:refine, :using].any? { |mth| ::Module.private_method_defined? mth }
  warn "corefines: Your Ruby doesn't support refinements, so I'll fake them."
  require 'corefines/support/fake_refinements'
end

require 'corefines/array'
require 'corefines/hash'
require 'corefines/module'
require 'corefines/object'
require 'corefines/set'
require 'corefines/string'
require 'corefines/symbol'
