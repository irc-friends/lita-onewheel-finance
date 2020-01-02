require "spec_helper"

def mock_up(filename)
  mock = File.open("spec/fixtures/#{filename}.json").read
  allow(RestClient).to receive(:get) { mock }
end

describe Lita::Handlers::OnewheelFinance, lita_handler: true do
  #it 'feds' do
  #
  #end

  it 'quotes up' do
    mock_up 'worldtradedata-quote-up'
    send_command 'quote lulu'
    expect(replies.last).to include("\u000314NASDAQ - \u0003LULU: \u000302$233.01\u0003")
    expect(replies.last).to include('(Lululemon Athletica Inc.)')
  end

  it 'quotes down' do
    mock_up 'worldtradedata-quote-down'
    send_command 'quote xlp'
    expect(replies.last).to include("\u000314NYSE - \u0003XLP: \u000302$62.51\u0003")
    expect(replies.last).to include('↯$-0.47')
    expect(replies.last).to include('(Consumer Staples Select Sector SPDR Fund)')
  end

  it 'errors' do
    mock_up 'worldtradedata-error'
    send_command 'quote in'
    expect(replies.last).to eq('`in` not found on any stock exchange.')
  end
end
