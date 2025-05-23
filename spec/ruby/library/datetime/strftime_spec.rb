require_relative '../../spec_helper'
require 'date'
require_relative '../../shared/time/strftime_for_date'
require_relative '../../shared/time/strftime_for_time'
date_version = defined?(Date::VERSION) ? Date::VERSION : '3.1.0'

describe "DateTime#strftime" do
  before :all do
    @new_date = -> y, m, d { DateTime.civil(y,m,d) }
    @new_time = -> *args { DateTime.civil(*args) }
    @new_time_in_zone = -> zone, offset, *args {
      y, m, d, h, min, s = args
      DateTime.new(y, m||1, d||1, h||0, min||0, s||0, Rational(offset, 24))
    }
    @new_time_with_offset = -> y, m, d, h, min, s, offset {
      DateTime.new(y,m,d,h,min,s, Rational(offset, 86_400))
    }

    @time = DateTime.civil(2001, 2, 3, 4, 5, 6)
  end

  it_behaves_like :strftime_date, :strftime
  it_behaves_like :strftime_time, :strftime

  # Differences with Time
  it "should be able to print the datetime with no argument" do
    @time.strftime.should == "2001-02-03T04:05:06+00:00"
    @time.strftime.should == @time.to_s
  end

  # %Z is %:z for Date/DateTime
  it "should be able to show the timezone with a : separator" do
    @time.strftime("%Z").should == "+00:00"
  end

  it "should be able to show the commercial week" do
    @time.strftime("%v").should == " 3-FEB-2001"
    @time.strftime("%v").should != @time.strftime('%e-%b-%Y')
  end

  # additional conversion specifiers only in Date/DateTime
  it 'shows the number of milliseconds since epoch' do
    DateTime.new(1970, 1, 1, 0, 0, 0).strftime("%Q").should == "0"
    @time.strftime("%Q").should == "981173106000"
    DateTime.civil(2001, 2, 3, 4, 5, Rational(6123, 1000)).strftime("%Q").should == "981173106123"
  end

  it "should be able to show a full notation" do
    @time.strftime("%+").should == "Sat Feb  3 04:05:06 +00:00 2001"
    @time.strftime("%+").should == @time.strftime('%a %b %e %H:%M:%S %Z %Y')
  end
end
