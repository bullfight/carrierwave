# encoding: utf-8

require 'zencoder'

module CarrierWave

  module Zencoder
    extend ActiveSupport::Concern
    
    module ClassMethods
      def create(outputs = {})
        process :create => [outputs]
      end
    end
      
    def create(outputs = {})
      file = File.dirname( current_path )      
      response = ::Zencoder::Job.create({:input => file, :outputs => outputs})
      response
    end
    
  end # Zencoder
end # CarrierWave