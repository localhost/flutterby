describe "Unsupported filters" do
  subject { node "index.html.poop", source: source }

  let(:source) { "poop!" }

  its(:full_name) { is_expected.to eq("index.html") }
  its(:render) { is_expected.to eq(source) }

  specify "logs a warning" do
    expect(Flutterby.logger)
      .to receive(:warn)
      .with("Unsupported filter 'poop'")

    subject.render
  end
end
