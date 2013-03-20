require 'spec_helper'

describe Capnotify::ComponentList do
  let(:component_list) { Capnotify::ComponentList.new }
  let(:component) { Capnotify::Component.new('MyComponent') }

  context "initialize" do
    it "should set #components to an empty array"
  end

  context "<<" do
    it "should append the component to the end of the list"
  end

  context "#insert" do
    it "should insert the component"
  end

  context "#prepend" do
    it "should prepend the component"
  end

  context "#append" do
    it "should add the component to the end of components"
  end

  context "#validate!" do

    context "when passing a Component" do
      it "should not raise an error" do
        lambda { component_list.send(:validate!, component) }.should_not raise_error
      end
    end

    context "when passing a non-Component" do
      it "should raise an ArgumentError" do
        lambda { component_list.send(:validate!, "test") }.should raise_error(ArgumentError)
      end
    end
  end

end
