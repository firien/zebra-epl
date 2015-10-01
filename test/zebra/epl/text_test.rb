# encoding: utf-8
require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::Text do
  it "can be initialized with the position of the text to be printed" do
    text = Zebra::Epl::Text.new position: [20, 40]
    text.position.must_equal [20,40]
    text.x.must_equal 20
    text.y.must_equal 40
  end

  it "can be initialized with the text rotation" do
    rotation = Zebra::Epl::Rotation::DEGREES_90
    text = Zebra::Epl::Text.new rotation: rotation
    text.rotation.must_equal rotation
  end

  it "can be initialized with the font to be used" do
    font = Zebra::Epl::Font::SIZE_1
    text = Zebra::Epl::Text.new font: font
    text.font.must_equal font
  end

  it "can be initialized with the horizontal multiplier" do
    multiplier = Zebra::Epl::HorizontalMultiplier::VALUE_1
    text = Zebra::Epl::Text.new h_multiplier: multiplier
    text.h_multiplier.must_equal multiplier
  end

  it "can be initialized with the vertical multiplier" do
    multiplier = Zebra::Epl::VerticalMultiplier::VALUE_1
    text = Zebra::Epl::Text.new v_multiplier: multiplier
    text.v_multiplier.must_equal multiplier
  end

  it "can be initialized with the data to be printed" do
    data = "foobar"
    text = Zebra::Epl::Text.new data: data
    text.data.must_equal data
  end

  it "can be initialized with the printing mode" do
    print_mode = Zebra::Epl::PrintMode::REVERSE
    text = Zebra::Epl::Text.new print_mode: print_mode
    text.print_mode.must_equal print_mode
  end
end

describe Zebra::Epl::Text, "#rotation=" do
  it "raises an error if the received rotation is invalid" do
    lambda {
      Zebra::Epl::Text.new.rotation = 4
    }.must_raise(Zebra::Epl::Rotation::InvalidRotationError)
  end
end

describe Zebra::Epl::Text, "#font=" do
  it "raises an error if the received font is invalid" do
    lambda {
      Zebra::Epl::Text.new.font = 6
    }.must_raise(Zebra::Epl::Font::InvalidFontError)
  end
end

describe Zebra::Epl::Text, "#h_multiplier=" do
  it "raises an error if the received multiplier is invalid" do
    lambda {
      Zebra::Epl::Text.new.h_multiplier = 9
    }.must_raise(Zebra::Epl::HorizontalMultiplier::InvalidMultiplierError)
  end
end

describe Zebra::Epl::Text, "#v_multiplier=" do
  it "raises an error if the received multiplier is invalid" do
    lambda {
      Zebra::Epl::Text.new.v_multiplier = 10
    }.must_raise(Zebra::Epl::VerticalMultiplier::InvalidMultiplierError)
  end
end

describe Zebra::Epl::Text, "#print_mode=" do
  it "raises an error if the received print mode is invalid" do
    lambda {
      Zebra::Epl::Text.new.print_mode = "foo"
    }.must_raise(Zebra::Epl::PrintMode::InvalidPrintModeError)
  end
end

describe Zebra::Epl::Text, "#to_epl" do
  let(:text) do
    Zebra::Epl::Text.new position: [100, 150], font: Zebra::Epl::Font::SIZE_3, data: "foobar"
  end

  it "raises an error if the X position was not informed" do
    text = Zebra::Epl::Text.new position: [nil, 100], data: "foobar"
    lambda {
      text.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the X value is not given")
  end

  it "raises an error if the Y position was not informed" do
    text = Zebra::Epl::Text.new position: [100, nil]
    lambda {
      text.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the Y value is not given")
  end

  it "raises an error if the font is not informed" do
    text = Zebra::Epl::Text.new position: [100, 100], data: "foobar"
    lambda {
      text.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the font to be used is not given")
  end

  it "raises an error if the data to be printed was not informed" do
    text.data = nil
    lambda {
      text.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the data to be printed is not given")
  end

  it "begins width the 'A' command" do
    text.to_epl.must_match /\AA/
  end

  it "assumes 1 as the default horizontal multipler" do
    text.to_epl.split(",")[4].to_i.must_equal Zebra::Epl::HorizontalMultiplier::VALUE_1
  end

  it "assumes 1 as the default vertical multiplier" do
    text.to_epl.split(",")[5].to_i.must_equal Zebra::Epl::VerticalMultiplier::VALUE_1
  end

  it "assumes the normal print mode as the default" do
    text.to_epl.split(",")[6].must_equal Zebra::Epl::PrintMode::NORMAL
  end

  it "assumes no rotation by default" do
    text.to_epl.split(",")[2].to_i.must_equal Zebra::Epl::Rotation::NO_ROTATION
  end
end
