require "spec_helper"

describe Sqs::Response do
  it "gets response type from name" do
    klass = Class.new(Sqs::Response) do
      def self.name
        "Sqs::DeleteFooResponse"
      end
    end

    klass.new(double("resposne", :body => "")).type.should == "DeleteFoo"
  end

  it "raises error if name is not properly formatted" do
    klass = Class.new(Sqs::Response) do
      def self.name
        "Sqs::DeleteFoo"
      end
    end

    lambda {
      klass.new(double("response", :body => "")).type
    }.should raise_error(/subclasses must have a name ending/)
  end

  it "contents of response" do
    klass = Class.new(Sqs::Response) do
      def self.name
        "Sqs::CreateFooResponse"
      end
    end

    xml = <<-XML
      <CreateFooResponse>
        <CreateFooResult>
          <Foo>
          </Foo>
        </CreteFooResult>
      </CreateFooResponse>
     XML

    response = double("response", :body => Nokogiri::XML(xml))
    response = klass.new(response)

    response.content.children.map(&:name).should include("Foo")
  end

  it "fetches request id" do
    klass = Class.new(Sqs::Response) do
      def self.name
        "Sqs::CreateFooResponse"
      end
    end

    xml = <<-XML
      <CreateFooResponse>
        <ResponseMetadata>
          <RequestId>
            b6633655-283d-45b4-aee4-4e84e0ae6afa
          </RequestId>
        </ResponseMetadata>
      </CreateFooResponse>
    XML

    response = double("response", :body => Nokogiri::XML(xml))
    response = klass.new(response)

    response.request_id == "b6633655-283d-45b4-aee4-4e84e0ae6afa"
  end
end
