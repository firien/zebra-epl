# encoding: utf-8
require 'minitest/spec'
require 'minitest/autorun'
require 'zebra/epl'

describe Zebra::Epl::CharacterSet do
  it "can be initialized with the number of data bits" do
    character_set = Zebra::Epl::CharacterSet.new number_of_data_bits: 8
    character_set.number_of_data_bits.must_equal 8
  end

  it "raises an error when receiving an invalid number of data bits" do
    lambda {
      Zebra::Epl::CharacterSet.new number_of_data_bits: 9
    }.must_raise(Zebra::Epl::CharacterSet::InvalidNumberOfDataBits)
  end

  it "can be initialized with the language" do
    character_set = Zebra::Epl::CharacterSet.new language: Zebra::Epl::Language::PORTUGUESE
    character_set.language.must_equal Zebra::Epl::Language::PORTUGUESE
  end

  it "raises an error with an invalid language" do
    lambda {
      Zebra::Epl::CharacterSet.new language: "G"
    }.must_raise(Zebra::Epl::Language::InvalidLanguageError)
  end

  it "can be initialized with the country code" do
    character_set = Zebra::Epl::CharacterSet.new country_code: Zebra::Epl::CountryCode::LATIN_AMERICA
    character_set.country_code.must_equal Zebra::Epl::CountryCode::LATIN_AMERICA
  end

  it "raises an error with an invalid country code" do
    lambda {
      Zebra::Epl::CharacterSet.new country_code: "999"
    }.must_raise(Zebra::Epl::CountryCode::InvalidCountryCodeError)
  end
end

describe Zebra::Epl::CharacterSet, "#to_epl" do
  let(:valid_attributes) do
    {
      number_of_data_bits: 8,
      language: Zebra::Epl::Language::PORTUGUESE,
      country_code: Zebra::Epl::CountryCode::LATIN_AMERICA
    }
  end
  let(:character_set) { Zebra::Epl::CharacterSet.new valid_attributes }
  let(:tokens) { character_set.to_epl.split(',') }

  it "raises an error if the number of data bits was not informed" do
    character_set = Zebra::Epl::CharacterSet.new valid_attributes.merge number_of_data_bits: nil
    lambda {
      character_set.to_epl
    }.must_raise(Zebra::Epl::CharacterSet::MissingAttributeError, "Can't set character set if the number of data bits is not given")
  end

  it "raises an error if the language was not informed" do
    character_set = Zebra::Epl::CharacterSet.new valid_attributes.merge language: nil
    lambda {
      character_set.to_epl
    }.must_raise(Zebra::Epl::CharacterSet::MissingAttributeError, "Can't set character set if the language is not given")
  end

  it "raises an error if the country code was not informed and the number of bits is 8" do
    character_set = Zebra::Epl::CharacterSet.new valid_attributes.merge country_code: nil
    lambda {
      character_set.to_epl
    }.must_raise(Zebra::Epl::CharacterSet::MissingAttributeError, "Can't set character set if the country code is not given")
  end

  it "raises an error if the country code was informed and the number of bits is 7" do
    character_set = Zebra::Epl::CharacterSet.new valid_attributes.merge country_code: Zebra::Epl::CountryCode::LATIN_AMERICA, number_of_data_bits: 7
    lambda {
      character_set.to_epl
    }.must_raise(Zebra::Epl::CharacterSet::CountryCodeNotApplicableForNumberOfDataBits)
  end

  it "does not raise an error if the country code was not informed and the number of data bits is 7" do
    character_set = Zebra::Epl::CharacterSet.new number_of_data_bits: 7, language: Zebra::Epl::Language::USA, country_code: nil
  end

  it "raises an error if the language is not supported by the given number of data bits" do
    lambda {
      Zebra::Epl::CharacterSet.new(number_of_data_bits: 7, language: Zebra::Epl::Language::LATIN_1_WINDOWS).to_epl
    }.must_raise(Zebra::Epl::Language::InvalidLanguageForNumberOfDataBitsError)
  end

  it "begins with the command 'I'" do
    character_set.to_epl.must_match /\AI/
  end

  it "contains the number of data bits" do
    tokens[0].match(/I(\d)/)[1].must_equal "8"
  end

  it "contains the language" do
    tokens[1].must_equal Zebra::Epl::Language::PORTUGUESE
  end

  it "contains the country code" do
    tokens[2].must_equal Zebra::Epl::CountryCode::LATIN_AMERICA
  end
end
