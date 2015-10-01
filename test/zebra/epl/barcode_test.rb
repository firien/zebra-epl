require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::Barcode do
  it "can be initialized with the position of the text to be printed" do
    barcode = Zebra::Epl::Barcode.new position: [20, 40]
    barcode.position.must_equal [20,40]
    barcode.x.must_equal 20
    barcode.y.must_equal 40
  end

  it "can be initialized with the barcode rotation" do
    rotation = Zebra::Epl::Rotation::DEGREES_90
    barcode = Zebra::Epl::Barcode.new rotation: rotation
    barcode.rotation.must_equal rotation
  end

  it "can be initialized with the barcode rotation" do
    rotation = Zebra::Epl::Rotation::DEGREES_90
    barcode = Zebra::Epl::Barcode.new rotation: rotation
    barcode.rotation.must_equal rotation
  end

  it "can be initialized with the barcode type" do
    type = Zebra::Epl::BarcodeType::CODE_128_C
    barcode = Zebra::Epl::Barcode.new type: type
    barcode.type.must_equal type
  end

  it "can be initialized with the narrow bar width" do
    barcode = Zebra::Epl::Barcode.new narrow_bar_width: 3
    barcode.narrow_bar_width.must_equal 3
  end

  it "can be initialized with the wide bar width" do
    barcode = Zebra::Epl::Barcode.new wide_bar_width: 10
    barcode.wide_bar_width.must_equal 10
  end

  it "can be initialized with the barcode height" do
    barcode = Zebra::Epl::Barcode.new height: 20
    barcode.height.must_equal 20
  end

  it "can be initialized informing if the human readable code should be printed" do
    barcode = Zebra::Epl::Barcode.new print_human_readable_code: true
    barcode.print_human_readable_code.must_equal true
  end

  describe "#rotation=" do
    it "raises an error if the received rotation is invalid" do
      lambda {
        Zebra::Epl::Barcode.new.rotation = 4
      }.must_raise(Zebra::Epl::Rotation::InvalidRotationError)
    end
  end

  describe "#type=" do
    it "raises an error if the received type is invalid" do
      lambda {
        Zebra::Epl::Barcode.new.type = "ZZZ"
      }.must_raise(Zebra::Epl::BarcodeType::InvalidBarcodeTypeError)
    end
  end

  describe "#narrow_bar_width=" do
    it "raises an error if the type is Code 128 and the width is invalid" do
      lambda {
        Zebra::Epl::Barcode.new type: Zebra::Epl::BarcodeType::CODE_128_AUTO, narrow_bar_width: 20
      }.must_raise(Zebra::Epl::Barcode::InvalidNarrowBarWidthError)
    end
  end

  describe "#wide_bar_width=" do
    it "raises an error if the type is Code 128 and the width is invalid" do
      lambda {
        Zebra::Epl::Barcode.new type: Zebra::Epl::BarcodeType::CODE_128_AUTO, wide_bar_width: 40
      }.must_raise(Zebra::Epl::Barcode::InvalidWideBarWidthError)
    end
  end

  describe "#print_human_readable_code" do
    it "defaults to false" do
      Zebra::Epl::Barcode.new.print_human_readable_code.must_equal false
    end
  end

  describe "#to_epl" do
    let(:valid_attributes) do
      {
        position:        [100, 150],
        type:            Zebra::Epl::BarcodeType::CODE_128_AUTO,
        height:          20,
        narrow_bar_width: 4,
        wide_bar_width:  6,
        data:            "foobar"
      }
    end
    let(:barcode) { Zebra::Epl::Barcode.new valid_attributes }
    let(:tokens) { barcode.to_epl.split(',') }

    it "raises an error if the X position was not informed" do
      barcode = Zebra::Epl::Barcode.new position: [nil, 100], data: "foobar"
      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the X value is not given")
    end

    it "raises an error if the Y position was not informed" do
      barcode = Zebra::Epl::Barcode.new position: [100, nil]
      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the Y value is not given")
    end

    it "raises an error if the barcode type is not informed" do
      barcode = Zebra::Epl::Barcode.new position: [100, 100], data: "foobar"
      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the barcode type to be used is not given")
    end

    it "raises an error if the data to be printed was not informed" do
      barcode.data = nil
      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the data to be printed is not given")
    end

    it "raises an error if the height to be used was not informed" do
      barcode.height = nil
      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the height to be used is not given")
    end

    it "raises an error if the narrow bar width is not given" do
      valid_attributes.delete :narrow_bar_width

      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the narrow bar width to be used is not given")
    end

    it "raises an error if the wide bar width is not given" do
      valid_attributes.delete :wide_bar_width

      lambda {
        barcode.to_epl
      }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the wide bar width to be used is not given")
    end

    it "begins with the command 'B'" do
      barcode.to_epl.must_match /\AB/
    end

    it "contains the X position" do
      tokens[0].match(/B(\d+)/)[1].must_equal "100"
    end

    it "contains the Y position" do
      tokens[1].must_equal "150"
    end

    it "contains the barcode rotation" do
      tokens[2].must_equal Zebra::Epl::Rotation::NO_ROTATION.to_s
    end

    it "contains the barcode type" do
      tokens[3].must_equal Zebra::Epl::BarcodeType::CODE_128_AUTO
    end

    it "contains the barcode narrow bar width" do
      tokens[4].must_equal "4"
    end

    it "contains the barcode wide bar width" do
      tokens[5].must_equal "6"
    end

    it "contains the barcode height" do
      tokens[6].must_equal "20"
    end

    it "contains the correct indication when the human readable code should be printed" do
      valid_attributes.merge! print_human_readable_code: true
      tokens[7].must_equal "B"
    end

    it "contains the correct indication when the human readable code should not be printed" do
      valid_attributes.merge! print_human_readable_code: false
      tokens[7].must_equal "N"
    end

    it "contains the data to be printed in the barcode" do
      tokens[8].must_equal "\"foobar\""
    end
  end
end
