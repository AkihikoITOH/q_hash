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
        ],
        job: nil
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
        },
        job: "Software Developer"
      }
    ]
  end

  let(:instance) { described_class.new(data) }

  describe "#find_by" do
    subject { instance.find_by(**conditions) }

    context "when the attribute exists" do
      context "when matching record exists" do
        let(:conditions) { {id: data.first[:id]} }

        it "finds the correct record" do
          expect(subject).to eq data.first
        end
      end

      context "when matching record does not exist" do
        let(:conditions) { {id: "abc"} }

        it { is_expected.to be_nil }
      end

      context "with proc condition" do
        let(:conditions) { {biometrics: ->(biometrics) { !biometrics.nil? }} }

        it "finds the correct record" do
          expect(subject).to eq data.last
        end
      end

      context "with nil condition" do
        let(:conditions) { {job: nil} }

        it "finds the correct record" do
          expect(subject).to eq data.first
        end
      end
    end

    context "when the attribute does not exist" do
      let(:conditions) { {name: "John Doe"} }

      it { is_expected.to be_nil }
    end
  end

  describe "#find_by!" do
    subject { instance.find_by!(**conditions) }

    context "when the attribute exists" do
      context "when matching record exists" do
        let(:conditions) { {id: data.first[:id]} }

        it "finds the correct record" do
          expect(subject).to eq data.first
        end
      end

      context "when matching record does not exist" do
        let(:conditions) { {id: "abc"} }

        it { expect { subject }.to raise_error QHash::RecordNotFound }
      end

      context "with proc condition" do
        let(:conditions) { {biometrics: ->(biometrics) { !biometrics.nil? }} }

        it "finds the correct record" do
          expect(subject).to eq data.last
        end
      end

      context "with nil condition" do
        let(:conditions) { {job: nil} }

        it "finds the correct record" do
          expect(subject).to eq data.first
        end
      end
    end

    context "when the attribute does not exist" do
      let(:conditions) { {name: "John Doe"} }

      it { expect { subject }.to raise_error QHash::RecordNotFound }
    end
  end

  describe "#where" do
    describe "single #where" do
      subject { instance.where(**conditions) }

      describe "single #where with top-level attribute" do
        let(:conditions) { {id: data.last[:id]} }

        it "returns an array with the correct record" do
          expect(subject).to contain_exactly(data.last)
        end
        it { is_expected.to be_a(QHash) }

        context "when there is no match" do
          let(:conditions) { {id: "abc"} }

          it "returns an empty array" do
            expect(subject).to match []
          end
          it { is_expected.to be_a(QHash) }
        end
      end

      describe "single #where with proc condition" do
        let(:conditions) { {id: ->(id) { id.is_a?(String) }} }

        it "returns an array with the correct records" do
          expect(subject).to contain_exactly(*data)
        end
        it { is_expected.to be_a(QHash) }
      end

      describe "single #where with nested attribute" do
        let(:conditions) { {address: {country: "Japan"}} }

        it "returns an array with the correct records" do
          expect(subject).to contain_exactly(*data)
        end
        it { is_expected.to be_a(QHash) }
      end

      describe "single #where with multiple nested attributes" do
        let(:conditions) do
          {
            address: {country: "Japan"},
            personal_info: {name: data.dig(0, :personal_info, :name)}
          }
        end

        it "returns an array with the correct record" do
          expect(subject).to contain_exactly(data.first)
        end
        it { is_expected.to be_a(QHash) }
      end
    end

    describe "chained #where" do
      subject do
        instance
          .where(address: {country: "Japan"})
          .where(personal_info: {name: data.dig(0, :personal_info, :name)})
      end

      it "returns an array with the correct record" do
        expect(subject).to contain_exactly(data.first)
      end
    end
  end

  describe "chaining #where and #find_by" do
    subject do
      instance
        .where(address: {country: "Japan", city: ["Tokyo", "Osaka"]})
        .where(biometrics: {height: ->(height) { height > 100 }})
        .find_by(id: data.last[:id])
    end

    it "returns the correct record" do
      expect(subject).to eq data.last
    end
  end
end
