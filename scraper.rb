# frozen_string_literal: true

require 'selenium-webdriver'

class Scraper
  def initialize(tracking_number)
    # Initilize the driver with our desired browser
    @driver = Selenium::WebDriver.for :chrome
    @tracking_number = tracking_number
    @driver.get 'https://www.17track.net/en'
    @wait = Selenium::WebDriver::Wait.new(timeout: 15) # seconds
  end

  def scrape
    fill_input(@driver, @wait, @tracking_number)
    submit_tracking_number(@driver, @wait)
    sleep 2

    @driver.quit # Close browser when the task is completed
  end

  private

  def fill_input(driver, wait, tracking_number)
    driver.find_element(:css, 'div > .modal-footer > .btn').click
    search_input = wait.until do
      driver.find_element(:css, 'div > .CodeMirror-line > span')
    end
    driver.action.send_keys(search_input, tracking_number).perform
  end

  def submit_tracking_number(driver, wait)
    submit_button = wait.until do
      driver.find_element(:css, 'div > .yq-tools-big > .btn-warning')
    end

    submit_button.click
    sleep 10

    driver.find_element(:class, 'introjs-skipbutton').click

    print_output(driver)
  rescue Selenium::WebDriver::Error::NoSuchElementError
    output = { error: 'Invalid tracking number' }
    puts output
  end

  def print_output(driver)
    package_status = driver.find_element(:css, 'div > .yqcr-ps').find_elements(:css, 'div > .text-capitalize')
    location = driver.find_element(:css, 'div > .to').find_elements(:css, 'div > span')
    date = driver.find_element(:css, 'div > .yqcr-last-event-pc').find_elements(:tag_name, 'time')

    output = {
      tracking_number: @tracking_number,
      package_location: location[0].text,
      status: package_status[0].text,
      last_update: date[0].text
    }

    puts output
  end
end

Scraper.new(4207306992748927005455000010756400).scrape
