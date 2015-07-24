#!/usr/bin/env rspec

require 'spec_helper'

describe 'jboss' do
  it { should contain_class 'jboss' }
end
