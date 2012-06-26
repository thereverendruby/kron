require 'kron_init.rb'

describe Kron::KronJob do

  before(:all) do
    @kj = Kron::KronJob.new
  end

  it 'Should Have no description' do
    @kj.description.should == '"No Desc."' 
  end

  it 'Should Have a description' do
    @kj.set_description('The Description')
    @kj.description.should == 'The Description'
  end

  it 'Current date/time should be' do
    dt='Tue Jan 03, 2012 12:30 PM'
    @kj.set_time_now(dt)
    @kj.current_time.strftime(TIME_FORMAT).should == dt
  end

  it 'Should run 1st 20 min interval' do
    @kj.every('tuesday', 'friday').every(20*60)
    @kj.set_time_now('Tue Jan 03, 2012 12:30 PM')
    @kj.set_time_now((@kj.current_time + (20*60)))
    @kj.run?.should be_true
  end

  it 'Should run 2nd 20 min interval' do
    @kj.set_time_now((@kj.current_time + (20*60)))
    @kj.run?.should be_true
  end

  it 'Should run 3rd 20 min interval' do
    @kj.set_time_now((@kj.current_time + (20*60)))
    @kj.run?.should be_true
  end

  it 'Day is Wed Should not run' do
    @kj.set_time_now('Wed Jan 04, 2012 12:30 PM')
    @kj.run?.should be_false
  end

  it 'Day is Fri Should run 1st 20 min interval' do
    @kj.set_time_now('Fri Jan 06, 2012 12:30 PM')
    @kj.set_time_now((@kj.current_time + (20*60)))
    @kj.run?.should be_true
  end

  it 'Day is Fri Should run 2nd 20 min interval' do
    @kj.set_time_now((@kj.current_time + (20*60)))
    @kj.run?.should be_true
  end
end

describe Kron::KronJob do

  before(:all) do
    @kj = Kron::KronJob.new.every('thursday', 'friday').at('9:56 am', '9:57 am')
  end

  it 'Should not run on Thursday at 9:50 am' do
    @kj.set_time_now('Thu Jan 05, 2012 9:50 AM')
    @kj.run?.should be_false
  end

  it 'Should not run on Thursday at 9:56 pm' do
    @kj.set_time_now('Thu Jan 05, 2012 9:56 PM')
    @kj.run?.should be_false
  end

  dt1='Thu Jan 05, 2012 09:56 AM'
  it "Current time should be #{dt1}" do
    @kj.set_time_now(dt1)
    @kj.current_time.strftime(TIME_FORMAT).should == dt1
  end

  it "Should run on #{dt1}" do
    @kj.run?.should be_true
  end
  
  dt2='Thu Jan 05, 2012 09:57 AM'
  it "Current time should be #{dt2}" do
    @kj.set_time_now(dt2)
    @kj.current_time.strftime(TIME_FORMAT).should == dt2
  end

  it "Should run on #{dt2}" do
    @kj.run?.should be_true
  end

  dt3='Fri Jan 06, 2012 09:56 AM'
  it "Current time should be #{dt3}" do
    @kj.set_time_now(dt3)
    @kj.current_time.strftime(TIME_FORMAT).should == dt3
  end

  it "Should run on #{dt3}" do
    @kj.run?.should be_true
  end
end

describe Kron::KronJob do

  before(:all) do
    @kj = Kron::KronJob.new.every(60) # seconds
  end

  it "Setting the minute" do
    dt="Fri Jan 06, 2012 09:#{@kj.minute} AM"
    @kj.set_time_now(dt)
    @kj.current_time.strftime(TIME_FORMAT).should == dt
  end

  it "First minute should run" do
    @kj.run?.should be_true
  end

  it "Setting the 2nd minute" do
    dt = (@kj.current_time + 60).strftime(TIME_FORMAT)
    @kj.set_time_now(dt)
    @kj.current_time.strftime(TIME_FORMAT).should == dt
  end

  it "Second minute should run" do
    @kj.run?.should be_true
  end
end

describe Kron::KronJob do

  before(:all) do
    @kj = Kron::KronJob.new.every('november', 'december').on_the(7, 18).at('3:00 pm', '4:30 am')
  end

  dt1='Wed Nov 07, 2012 04:30 AM'
  it "Current time should be #{dt1}" do
    @kj.set_time_now(dt1)
    @kj.current_time.strftime(TIME_FORMAT).should == dt1
  end

  it "Should run on #{dt1}" do
    @kj.run?.should be_true
  end

  dt11='Wed Nov 07, 2012 03:00 PM'
  it "Current time should be #{dt11}" do
    @kj.set_time_now(dt11)
    @kj.current_time.strftime(TIME_FORMAT).should == dt11
  end

  it "Should run on #{dt11}" do
    @kj.run?.should be_true
  end

  dt2='Thu Nov 08, 2012 04:30 AM'
  it "Current time should be #{dt2}" do
    @kj.set_time_now(dt2)
    @kj.current_time.strftime(TIME_FORMAT).should == dt2
  end

  it "Should run on #{dt2}" do
    @kj.run?.should be_false
  end

  dt22='Thu Nov 08, 2012 03:00 PM'
  it "Current time should be #{dt22}" do
    @kj.set_time_now(dt22)
    @kj.current_time.strftime(TIME_FORMAT).should == dt22
  end

  it "Should run on #{dt22}" do
    @kj.run?.should be_false
  end

  dt3='Fri Dec 07, 2012 04:30 AM'
  it "Current time should be #{dt3}" do
    @kj.set_time_now(dt3)
    @kj.current_time.strftime(TIME_FORMAT).should == dt3
  end

  it "Should run on #{dt3}" do
    @kj.run?.should be_true
  end

  dt33='Fri Dec 07, 2012 03:00 PM'
  it "Current time should be #{dt33}" do
    @kj.set_time_now(dt33)
    @kj.current_time.strftime(TIME_FORMAT).should == dt33
  end

  it "Should run on #{dt33}" do
    @kj.run?.should be_true
  end

  dt4='Sat Dec 08, 2012 04:30 AM'
  it "Current time should be #{dt4}" do
    @kj.set_time_now(dt4)
    @kj.current_time.strftime(TIME_FORMAT).should == dt4
  end

  it "Should run on #{dt4}" do
    @kj.run?.should be_false
  end
  
  dt5='Sun Nov 18, 2012 04:30 AM'
  it "Current time should be #{dt5}" do
    @kj.set_time_now(dt5)
    @kj.current_time.strftime(TIME_FORMAT).should == dt5
  end

  it "Should run on #{dt5}" do
    @kj.run?.should be_true
  end
  
  dt55='Sun Nov 18, 2012 04:30 AM'
  it "Current time should be #{dt55}" do
    @kj.set_time_now(dt55)
    @kj.current_time.strftime(TIME_FORMAT).should == dt55
  end

  it "Should run on #{dt55}" do
    @kj.run?.should be_true
  end
  
  dt6='Tue Dec 18, 2012 04:30 AM'
  it "Current time should be #{dt6}" do
    @kj.set_time_now(dt6)
    @kj.current_time.strftime(TIME_FORMAT).should == dt6
  end

  it "Should run on #{dt6}" do
    @kj.run?.should be_true
  end
end
