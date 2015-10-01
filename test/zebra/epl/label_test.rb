# encoding: utf-8
require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::Label, "#new" do
  it "sets the label width" do
    label = Zebra::Epl::Label.new width: 300
    label.width.must_equal 300
  end

  it "sets the label length/gap" do
    label = Zebra::Epl::Label.new length_and_gap: [400, 24]
    label.length.must_equal 400
    label.gap.must_equal 24
  end

  it "sets the printing speed" do
    label = Zebra::Epl::Label.new print_speed: 2
    label.print_speed.must_equal 2
  end

  it "sets the number of copies" do
    label = Zebra::Epl::Label.new copies: 4
    label.copies.must_equal 4
  end

  it "the number of copies defaults to 1" do
    label = Zebra::Epl::Label.new
    label.copies.must_equal 1
  end

  it "validates the printing speed" do
    [-1, 8, "a"].each do |s|
      lambda {
        Zebra::Epl::Label.new print_speed: s
      }.must_raise(Zebra::Epl::Label::InvalidPrintSpeedError)
    end
  end

  it "sets the print density" do
    label = Zebra::Epl::Label.new print_density: 10
    label.print_density.must_equal 10
  end

  it "validates the print density" do
    [-1, 16, "a"].each do |d|
      lambda {
        Zebra::Epl::Label.new print_density: d
      }.must_raise(Zebra::Epl::Label::InvalidPrintDensityError)
    end
  end
end

describe Zebra::Epl::Label, "#<<" do
  it "adds an item to the list of label elements" do
    label = Zebra::Epl::Label.new print_speed: 2
    element_count = label.elements.count
    label << Zebra::Epl::Text.new(position: [20, 40])
    label.elements.count.must_equal(element_count+1)
  end
end

FakeEpl = Struct.new(:to_epl)
  
describe Zebra::Epl::Label, "#dump_contents" do
  let(:label) do
    Zebra::Epl::Label.new print_speed: 2
  end

  it "dumps its contents to the received IO" do
    label << FakeEpl.new('foobar')
    label << FakeEpl.new('blabla')
    label.width          = 100
    label.length_and_gap = [200, 24]
    label.print_speed    = 3
    label.print_density  = 10
    io = label.to_s
    io.must_equal "O\nQ200,24\nq100\nS3\nD10\n\nN\nfoobar\nblabla\nP1\n"
  end

  it "does not try to set the label width when it's not informed (falls back to autosense)" do
    io = label.to_s
    io.wont_match /q/
  end

  it "does not try to set the length/gap when they were not informed (falls back to autosense)" do
    io = label.to_s
    io.wont_match /Q/
  end

  it "does not try to set the print density when it's not informed (falls back to the default value)" do
    io = label.to_s
    io.wont_match /D/
  end

  it "raises an error if the print speed was not informed" do
    label = Zebra::Epl::Label.new
    lambda {
      io = label.to_s
    }.must_raise(Zebra::Epl::Label::PrintSpeedNotInformedError)
  end
end
