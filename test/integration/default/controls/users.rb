title 'Verify creation and removal of users'

describe user('foo') do
    it { should exist }
    its('home') { should eq '/home/foo_home' }
    its('shell') { should eq '/bin/sh' }
    its('group') { should eq 'users' }
end

describe user('bar') do
    it { should exist }
    its('home') { should eq '/srv/bar' }
    its('uid') { should be < 1000 }
end
