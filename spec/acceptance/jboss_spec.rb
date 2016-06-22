require 'spec_helper_acceptance'

describe 'tomcat' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include stdlib
        include stdlib::stages
        include profile::package_management

        $tomcat_version = '7.0.65-3.cgk.el6'
        $tomcat_instance_root_dir = '/opt'
        class { 'cegekarepos' : stage => 'setup_repo' }
        
        Yum::Repo <| title == 'cegeka-custom' |>
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
        Yum::Repo <| title == 'cegeka-unsigned' |>
        
        sunjdk::instance { 'jdk-1.7.0_06-fcs':
          ensure      => 'present',
          jdk_version => '1.7.0_06-fcs'
        }

        class { 'jboss':
          version       => '6.3.0-2.cgk.el6',
          jboss_log_dir => '/tmp/'
        }

      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('jboss63') do
      it { should be_installed }
    end
    describe process('java') do
      it { should be_running }
      its(:user) { should eq 'jboss' }
    end

  end
end
