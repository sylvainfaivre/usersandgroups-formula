title 'Verify files'

describe file('/home/foo_home/foo-file') do
  it { should exist }
  it { should be_file }
  its('content') { should match /foo file/ }
end

describe file('/srv/bar/default-file') do
  it { should exist }
  it { should be_file }
  its('content') { should match /default file/ }
end

describe file('/srv/foobar/default-file') do
  it { should exist }
  it { should be_file }
  its('content') { should match /default file/ }
end

