require 'rails_helper'

class Widget
  include Model
end

RSpec.describe Model, '.create' do
  before { clear_redis! }

  it "returns a new instance of the class" do
    widget = Widget.create "abc123"
    expect(widget).to be_instance_of Widget
  end

  it "does not create duplicates" do
    expect($redis.zcard('widgets')).to eql 0
    Widget.create "abc123"
    Widget.create "abc123"
    Widget.create "abc123"
    expect($redis.zcard('widgets')).to eql 1
  end
end

RSpec.describe Model, '.all' do
  before { clear_redis! }

  it "returns all widgets ordered newest-first" do
    widget1 = Widget.create "widget1"
    widget2 = Widget.create "widget2"
    widget3 = Widget.create "widget3"
    expect(Widget.all).to match_array [widget3, widget2, widget1]
  end
end

RSpec.describe Widget, '.retrieve' do
  before { clear_redis! }

  it "returns the widget" do
    widget1 = Widget.create "widget1"
    expect(Widget.retrieve("widget1").id).to eql "widget1"
  end

  it "raises when the widget does not exist" do
    expect {
      Widget.retrieve("nonexistent-widget")
    }.to raise_exception Widget::NotFound
  end
end

RSpec.describe Widget, '.next' do
  before { clear_redis! }

  it "returns the next model" do
    widget1 = Widget.create "widget1", Date.today
    widget2 = Widget.create "widget2", Date.today + 1.day
    widget3 = Widget.create "widget3", Date.today + 2.days
    expect(Widget.next(widget3.id)).to eq widget2
    expect(Widget.next(widget2.id)).to eq widget1
    expect(Widget.next(widget1.id)).to eq widget3
  end
end

RSpec.describe Widget, '.prev' do
  before { clear_redis! }

  it "returns the previous model" do
    widget1 = Widget.create "widget1", Date.today
    widget2 = Widget.create "widget2", Date.today + 1.day
    widget3 = Widget.create "widget3", Date.today + 2.days
    expect(Widget.prev(widget1.id)).to eq widget2
    expect(Widget.prev(widget2.id)).to eq widget3
    expect(Widget.prev(widget3.id)).to eq widget1
  end
end

RSpec.describe Widget, '#next' do
  before { clear_redis! }

  it "returns the next model" do
    widget1 = Widget.create "widget1"
    widget2 = Widget.create "widget2"
    expect(Widget).to receive(:next).with("widget1").and_return(widget2)
    expect(widget1.next).to eq widget2
  end
end

RSpec.describe Widget, '#prev' do
  before { clear_redis! }

  it "returns the previous model" do
    widget1 = Widget.create "widget1"
    widget2 = Widget.create "widget2"
    expect(Widget).to receive(:prev).with("widget2").and_return(widget1)
    expect(widget2.prev).to eq widget1
  end
end

