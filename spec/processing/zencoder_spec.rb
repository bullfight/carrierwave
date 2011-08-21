# encoding: utf-8

require 'spec_helper'

for credential in FOG_CREDENTIALS
  zencoder_fog_tests(credential)
end
