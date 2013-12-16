module RiotApi
  # Public: Converts parsed response bodies to a Hashie::Rash if they were of
  # Hash or Array type.
  class Rashify < Mashify
    dependency do
      require 'rash'
      self.mash_class = ::Hashie::Rash
    end
  end
end