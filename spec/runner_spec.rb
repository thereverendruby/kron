require 'kron_init.rb'

describe Kron, 'Should' do
  before(:all) do
    @runner = Kron::Runner.new
  end

  it 'Not be running' do
    @runner.running?.should be_nil
  end

  it 'Be running' do
    @runner.start
    @runner.running?.should_not be_nil 
  end

  it 'Not Start: Already running' do
    @runner.start.should be_instance_of(Kron::Runner)
  end

  it 'Have no jobs running' do
    @runner.number_of_jobs.should equal 0
  end

  it 'Have 1 job running' do
    kj = Kron::KronJob.new
    @runner.add_job(kj)
    @runner.number_of_jobs.should equal 1
  end

  it 'Have 2 jobs running' do
    kj = Kron::KronJob.new
    @runner.add_job(kj)
    @runner.number_of_jobs.should equal 2
  end

  it 'Interval be 60 seconds' do
    @runner.interval.should == 60
  end

  it 'Interval be 10 seconds' do
    @runner.set_interval(10)
    @runner.interval.should == 10
  end

  it 'Be stopped' do
    @runner.stop
    @runner.running?.should be_nil
  end
end
