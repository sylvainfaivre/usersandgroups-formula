title 'Verify SSH keys'

describe file('/home/foo_home/.ssh/authorized_keys') do
  it { should exist }
  it { should be_file }
  f = File.open('test/salt/ssh_keys/foo.pub')
  its('content') { should eq f.read }
end

describe file('/srv/bar/.ssh/authorized_keys') do
  it { should exist }
  it { should be_file }
  f = File.open('test/salt/ssh_keys/bar.pub')
  its('content') { should eq f.read }
end
