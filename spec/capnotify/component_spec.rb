require 'spec_helper'

describe Capnotify::Component do

  context "initialization" do

    it "should set the name to the symbol" do
      Capnotify::Component.new('new_component').name.should == :new_component
    end

    it "should set the header if specified" do
      Capnotify::Component.new('asdf', :header => 'spike').header.should == 'spike'
    end

    it "should set the css_class if specified" do
      Capnotify::Component.new('asdf', :css_class => 'great-component').css_class.should == 'great-component'
    end

  end

  context "#content=" do

    context "when given invalid content type" do
      class MyContent;end

      let(:new_content) { MyContent.new }
      let(:component) { Capnotify::Component.new('component') }

      it "should raise an error" do
        lambda { component.content = new_content }.should raise_error(ArgumentError)
      end
    end

  end

end
