# encoding: utf-8
require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::Box do
  it "can be initialized with initial position" do
    box = Zebra::Epl::Box.new position: [20, 40]
    box.position.must_equal [20, 40]
    box.x.must_equal 20
    box.y.must_equal 40
  end

  it "can be initialized with the end position" do
    box = Zebra::Epl::Box.new end_position: [20, 40]
    box.end_position.must_equal [20, 40]
    box.end_x.must_equal 20
    box.end_y.must_equal 40
  end

  it "can be initialized with the line thckness " do
    box = Zebra::Epl::Box.new line_thickness: 3
    box.line_thickness.must_equal 3
  end
end

describe Zebra::Epl::Box, "#to_epl" do
  let(:attributes) do
    {
      position: [20,40],
      end_position: [60, 100],
      line_thickness: 3
    }
  end

  it "raises an error if the X position was not informed" do
    box = Zebra::Epl::Box.new attributes.merge(position: [nil, 40])
    lambda {
      box.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the X value is not given")
  end

  it "raises an error if the Y position was not informed" do
    box = Zebra::Epl::Box.new attributes.merge(position: [20, nil])
    lambda {
      box.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the Y value is not given")
  end

  it "raises an error if the end X position was not informed" do
    box = Zebra::Epl::Box.new attributes.merge(end_position: [nil, 40])
    lambda {
      box.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the horizontal end position (X) is not given")
  end

  it "raises an error if the end Y position was not informed" do
    box = Zebra::Epl::Box.new attributes.merge(end_position: [20, nil])
    lambda {
      box.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the vertical end position (Y) is not given")
  end

  it "raises an error if the line thickness was not informed" do
    box = Zebra::Epl::Box.new attributes.merge(line_thickness: nil)
    lambda {
      box.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the line thickness is not given")
  end

  it "begins with the 'X' command" do
    box = Zebra::Epl::Box.new attributes
    box.to_epl.must_match /\AX/
  end

  it "contains the attributes in correct order" do
    box = Zebra::Epl::Box.new attributes
    box.to_epl.must_equal "X20,40,3,60,100"
  end
end

