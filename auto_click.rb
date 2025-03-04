require 'selenium-webdriver'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'tmpdir'

HOME_URL = "https://ap17.bipocloud.com/SLL/Login"


# 需要設定的 ENV
# LINE_CHANNEL_ACCESS_TOKEN: 用於發送 Line 通知的存取權杖
# LINE_USER_ID: 接收 Line 通知的使用者 ID
# BIPOID: 用於登入 BIPO 的使用者 ID
# BIPOPASSWORD: 用於登入 BIPO 的密碼



def send_line_notification(message)
  uri = URI.parse("https://api.line.me/v2/bot/message/push")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"
  request["Content-Type"] = "application/json"
  request.body = {
    to: ENV['LINE_USER_ID'],
    messages: [
      {
        type: "text",
        text: message
      }
    ]
  }.to_json

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end

  puts "Line notification sent: #{response.body}"
end



options = Selenium::WebDriver::Chrome::Options.new
Dir.mktmpdir do |dir|
  unique_dir = "#{dir}_#{Time.now.to_i}"
  options.add_argument("--user-data-dir=#{unique_dir}")
  options.add_argument(' - headless')
  options.add_argument(' - no-sandbox')
  options.add_argument(' - disable-dev-shm-usage')
  driver = Selenium::WebDriver.for :chrome, options: options
  
  begin
    driver.navigate.to HOME_URL
  
    # login 
    login_input = driver.find_element(id: 'txtLoginID')
    login_input.send_keys(ENV['BIPOID'])
    login_input = driver.find_element(id: 'txtPassword')
    
    login_input.send_keys(ENV['BIPOPASSWORD'])
    driver.find_element(id: 'btnLogin').click
  
    sleep(rand(5..10))
    # goto clock page
    url = 'https://ap17.bipocloud.com/SLL/EMP/SSApp/?id=87FEFE3129B85A9C'
    driver.navigate.to url
  



    sleep(rand(10..120))
    Selenium::WebDriver::Wait.new(timeout: 10).until { driver.find_element(:id,  'btnClock') }.click
  
    sleep(2)
    line_message = []
    clocking_history = driver.find_element(:id, 'ClockingHistory').text
    
    line_message << clocking_history
    line_message << "  \n\n"
    line_message << "Check-in completed. #{Time.now}"
    puts line_message.join('')
    send_line_notification(line_message.join(''))
  
  rescue => e
    puts "Error: #{e}"
    send_line_notification("Error: #{e}")
  ensure
    driver.quit
  end
end


