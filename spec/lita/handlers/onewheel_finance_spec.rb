require "spec_helper"

def mock_up(filename)
  mock = File.open("spec/fixtures/#{filename}.json").read
  allow(RestClient).to receive(:get) { mock }
end

describe Lita::Handlers::OnewheelFinance, lita_handler: true do  

  it 'quotes up' do
    mock_up 'worldtradedata-quote-up'    
    registry.config.handlers.onewheel_finance.handler = 'worldtradedata'    
    send_command 'quote lulu'
    expect(replies.last).to include(" LULU: $233.01 \u000303 $1.34\u0003, \u0003030.58%\u0003")    
  end

  it 'quotes yahoo' do
    mock_up 'yahoo-quote'
    registry.config.handlers.onewheel_finance.handler = 'yahoo'    
    send_command 'quote zm'
    expect(replies.last).to include(" ZM: $179.75 \u000303 $10.66\u0003, \u0003036.3%\u0003")    
  end

  it 'quotes down' do
    mock_up 'worldtradedata-quote-down'
    registry.config.handlers.onewheel_finance.handler = 'worldtradedata'       
    send_command 'quote xlp'
    expect(replies.last).to include("XLP: $62.51 \u000304 $-0.47\u0003, \u000304-0.75%\u0003")    
  end

  it 'nasdaq:lulu' do
    mock_up 'worldtradedata-quote-up'
    registry.config.handlers.onewheel_finance.handler = 'worldtradedata'       
    send_command 'q nasdaq:lulu'
    expect(replies.last).to include(" LULU: $233.01 \u000303 $1.34\u0003, \u0003030.58%\u0003")
  end

  it 'removes $ from ^ reqs' do
    mock_up 'worldtradedata-quote-dji'
    registry.config.handlers.onewheel_finance.handler = 'worldtradedata'     
    send_command 'q ^dji'
    expect(replies.last).to include(" ^DJI: 25766.64 \u000304 -1190.95\u0003, \u000304-4.42%\u0003")
  end  
end
