require 'kron_init.rb'

describe Kron::KronJob do

  year1 = Time.now.strftime('%Y')
  year2 = year1.to_i + 1

  before(:all) do
    @runner = Kron::Runner.new(1)
    @runner.start
    @kj = Kron::KronJob.new.on("Dec 20, #{year1}", "Jan, 10 #{year2}").at('3:02 pm', '4:39 am')
    @runner << @kj
  end

  it 'Not Be Started Again' do
    (!@runner and !@runner.running?).should be_false # tests the documentation example
  end

  it 'Runner Should Have 1 Job' do 
    @runner.jobs.size.should == 1
  end

  dt1="Thu Dec 20, #{year1} 04:39 AM"
  it "Current time should be #{dt1}" do
    @kj.set_time_now(dt1)
    @kj.current_time.strftime(TIME_FORMAT).should == dt1
  end

  it "Should run once on #{dt1}" do
    @kj.run?.should be_true
    sleep 2
  end

  dt2="Thu Jan 10, #{year2} 04:39 AM"
  it "Current time should be #{dt2}" do
    @kj.set_time_now(dt2)
    @kj.current_time.strftime(TIME_FORMAT).should == dt2
  end

  it "Should run once on #{dt2}" do
    @kj.run?.should be_true
    sleep 1
  end

  dt3="Thu Dec 20, #{year1} 03:02 PM"
  it "Current time should be #{dt3}" do
    @kj.set_time_now(dt3)
    @kj.current_time.strftime(TIME_FORMAT).should == dt3
  end

  it "Should run once on #{dt3}" do
    @kj.run?.should be_true
    sleep 1
  end

  it 'Should have pending jobs' do
    @kj.has_pending_jobs?.should be_true
  end

  it 'Runner number of jobs should be 1' do
    @runner.number_of_jobs.should == 1
  end

  dt4="Thu Jan 10, #{year2} 03:02 PM"
  it "Current time should be #{dt4}" do
    @kj.set_time_now(dt4)
    @kj.current_time.strftime(TIME_FORMAT).should == dt4
  end

  it "Should run once on #{dt4}" do
    @kj.run?.should be_true
    sleep 1
  end

  it 'Should have no pending jobs' do
    @kj.has_pending_jobs?.should be_false
  end

  it 'Runner number of jobs should be 0' do
    @runner.number_of_jobs.should == 0
  end
end
