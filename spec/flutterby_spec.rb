require "spec_helper"

describe Flutterby do
  it "has a version number" do
    expect(Flutterby::VERSION).not_to be nil
  end

  describe ".from" do
    let(:site_path) { ::File.expand_path("../site/", __FILE__) }

    context "when a directory is passed as an argument" do
      subject { Flutterby.from site_path }

      it "returns a Folder instance" do
        expect(subject).to be_a(Flutterby::Folder)
      end

      it "name should match the directory name by default" do
        expect(subject.name).to eq("site")
      end
    end

    context "when a file is passed as an argument" do
      subject { Flutterby.from ::File.join(site_path, "markdown.html.md") }

      it "returns a File instance" do
        expect(subject).to be_a(Flutterby::File)
      end
    end

    context "when an invalid path is passed as an argument" do
      subject { Flutterby.from "whahahaahah_nil" }

      it "raises an exception" do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end