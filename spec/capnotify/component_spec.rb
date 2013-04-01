require 'spec_helper'

describe Capnotify::Component do
  let(:component) { Capnotify::Component.new(:test_component) }

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

    it "should set the css_class to the default 'section' if not specified" do
      Capnotify::Component.new('asdf').css_class.should == 'section'
    end

    it "should allow building with a block" do
      c = Capnotify::Component.new(:test_component) do |c|
        c.header = 'My Header'

        c.content = {}
        c.content['this is'] = 'a test'
      end

      c.builder.should_not be_nil
      c.header.should be_nil

      c.build!

      c.header.should == 'My Header'
      c.builder.should be_nil
    end
  end

  context "#render_content" do
    let(:sample_content) { "This is sample content that just works." }

    before do
      component.content = sample_content
    end

    context "when using an existing renderer" do

      it "should render data" do
        component.renderers[:txt].should_not be_nil
        component.render_content(:txt).should match(sample_content)
      end

    end

    context "when a template is missing" do

      it "should raise an error" do
        component.render_for :txt => 'does_not_exist.erb'
        expect { component.render_content(:txt) }.to raise_error
      end

    end

    context "when a template is not defined" do

      it "should return an empty string" do
        component.renderers[:foo].should be_nil
        component.render_content(:foo).should == ''
      end

    end

  end

  context "#template_path_for" do

    it "should raise a TemplateUndefined error if the renderer is not defined" do
      lambda { component.template_path_for(:foo) }.should raise_error(Capnotify::Component::TemplateUndefined)
    end

  end

  context "#render_for" do

    it "should add new renderers" do
      expect { component.render_for :other => 'asdf.erb', :more => 'more.erb' }.to change { component.renderers.keys.count }.by(2)
    end

    it "should override existing renderers" do
      expect { component.render_for :html => 'new_html.erb' }.to change { component.renderers.keys.count }.by(0)

      component.renderers[:html].should == 'new_html.erb'
    end

  end

end
