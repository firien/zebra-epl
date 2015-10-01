# encoding: utf-8
require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::Qrcode do
  it "can be initialized with the scale factor" do 
    qrcode = Zebra::Epl::Qrcode.new scale_factor: 3
    qrcode.scale_factor.must_equal 3
  end 

  it "can be initialized with the error correction level" do
    qrcode = Zebra::Epl::Qrcode.new correction_level: "M"
    qrcode.correction_level.must_equal "M"
  end
end

describe Zebra::Epl::Qrcode, "#scale_factor" do
  it "raises an error if the scale factor is not within the range 1-99" do
    lambda {
      Zebra::Epl::Qrcode.new scale_factor: 100
    }.must_raise(Zebra::Epl::Qrcode::InvalidScaleFactorError)
  end
end

describe Zebra::Epl::Qrcode, "#correction_level" do
  it "raises an error if the error correction_level not in [LMQH]" do
    lambda {
      Zebra::Epl::Qrcode.new correction_level: "A"
    }.must_raise(Zebra::Epl::Qrcode::InvalidCorrectionLevelError)
  end
end              

describe Zebra::Epl::Qrcode, "#to_epl" do
  let(:valid_attributes) { {
    position:         [50, 50],
    scale_factor:     3,
    correction_level: "M",
    data:             "foobar"
  }}
  let(:qrcode) { Zebra::Epl::Qrcode.new valid_attributes }
  let(:tokens) { qrcode.to_epl.split(",") }

  it "raises an error if the X position is not given" do
    qrcode = Zebra::Epl::Qrcode.new position: [nil, 50], data: "foobar"
    lambda {
      qrcode.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the X value is not given")
  end

  it "raises an error if the Y position is not given" do
    qrcode = Zebra::Epl::Qrcode.new position: [50, nil], data: "foobar"
    lambda {
      qrcode.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the Y value is not given")
  end      

  it "raises an error if the data to be printed was not informed" do
    qrcode.data = nil
    lambda {
      qrcode.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the data to be printed is not given")
  end  
  
  it "raises an error if the scale factor is not given" do
    valid_attributes.delete :scale_factor
    lambda {
      qrcode.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the scale factor to be used is not given")
  end

  it "raises an error if the correction level is not given" do
    valid_attributes.delete :correction_level
    lambda {
      qrcode.to_epl
    }.must_raise(Zebra::Epl::Printable::MissingAttributeError, "Can't print if the error correction level to be used is not given")
  end  

  it "begins with the command 'b'" do
    qrcode.to_epl.must_match /\Ab/
  end 

  it "contains the X position" do
    tokens[0].match(/b(\d+)/)[1].must_equal "50"
  end

  it "contains the Y position" do
    tokens[1].must_equal "50"
  end

  it "contains QR code type" do
    tokens[2].must_equal "Q"
  end

  it "contains the scale factor" do
    tokens[3].must_equal "s3"
  end

  it "contains the error correction level" do
    tokens[4].must_equal "eM"
  end

  it "contains the data to be printed in the qrcode" do
    tokens[5].must_equal "\"foobar\""
  end
end
