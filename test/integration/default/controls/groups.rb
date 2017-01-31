title 'Verify creation and removal of groups'

describe group('foo') do
    it { should_not exist }
end

describe group('bar') do
    it { should exist }
end

describe group('users') do
    it { should exist }
    its('gid') { should eq 1001 }
end
