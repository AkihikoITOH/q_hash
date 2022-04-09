# frozen_string_literal: true

RSpec.describe QHash do
  let(:data) do
    [
      {
        id: "da9d517e-eb1b-4f5b-8fec-c1258eda0db2",
        personal_info: {
          name: "John Doe",
          date_of_birth: "1900-01-01"
        },
        address: {
          country: "Japan",
          city: "Tokyo"
        },
        hobbies: [
          "jogging",
          "eating",
          "sleeping"
        ]
      },
      {
        id: "fab15d98-47d6-4552-a6e6-0b83de0b532b",
        personal_info: {
          name: "John Doe Jr.",
          date_of_birth: "2000-01-01"
        },
        address: {
          country: "Japan",
          city: "Tokyo"
        },
        biometrics: {
          height: 200,
          weight: 100
        }
      }
    ]
  end

  let(:instance) { described_class.new(data) }

  describe "#find_by_attribute" do
    context "when the attribute exists" do
      context "when matching record exists" do
        subject { instance.find_by_id(data.first[:id]) }

        it "finds by the attribute" do
          expect(subject).to eq data.first
        end
      end

      context "when matching record does not exist" do
        subject { instance.find_by_id("abc") }

        it { is_expected.to be_nil }
      end
    end

    context "when the attribute does not exist" do
      subject { instance.find_by_name("John Doe") }

      it { is_expected.to raise_error(NoMethodError) }
    end
  end

  describe "single #where with top-level attribute" do
    subject { instance.where(id: data.last[:id]) }

    it "returns an array with the correct record" do
      expect(subject).to eq [data.last]
    end
  end

  describe "single #where with nested attribute" do
    subject { instance.where(address: {country: "Japan"}) }

    it "returns an array with the correct records" do
      expect(subject).to eq data
    end
  end

  describe "single #where with multiple nested attributes" do
    subject do
      instance
        .where(
          address: {country: "Japan"},
          personal_info: {name: data.dig(0, :personal_info, :name)}
        )
    end

    it "returns an array with the correct record" do
      expect(subject).to eq [data.first]
    end
  end

  describe "chained #where" do
    subject do
      instance
        .where(address: {country: "Japan"})
        .where(personal_info: {name: data.dig(0, :personal_info, :name)})
    end

    it "returns an array with the correct record" do
      expect(subject).to eq [data.first]
    end
  end
end
