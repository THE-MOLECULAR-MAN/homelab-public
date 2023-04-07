#!/usr/bin/python3
"""Selenium script for Python will do a soft/safe reboot on a
   Verizon 4G LTE Network Extender (ASK-SFE116)"""
# Tim H 2023
#   This Selenium script for Python will do a soft/safe reboot on a
#   Verizon 4G LTE Network Extender. My network extender has issues after
#   being powered on for over a week or so, and there is no way in the GUI
#   to schedule or automate reboots. This script logs into the web interface
#   and simulates clicking the soft reboot button.
#   Takes about 3-4 minutes to finish rebooting and restarting all services.
#   SKU: ASK-SFE116
#   FCC ID: H8N-ASK-SFE116
#
#   Developed in the following environment, known to be working:
#       * Verizon Network Extender software version: GA5.11 - V0.5.011.1322
#       * macOS 13.3 (Ventura)
#       * Python 3.9.6
#       * Selenium 4.8.3
#
# References:
#   https://www.geeksforgeeks.org/driving-headless-chrome-with-python/
#   https://www.thepythoncode.com/article/automate-login-to-websites-using-selenium-in-python
#   https://www.verizon.com/support/lte-network-extender/

from time import sleep
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By


def main():
    """Docstring here"""
    # HTTPS URL for the Verizon LTE Extender management page
    # it's just regular HTTPS over TCP 443
    url_to_render = 'https://10.0.1.19/'

    # this is the password used to login. There is no username
    # the factory password is printed on a label on the Verizon device.
    password_to_use = 'redacted'

    options = Options()
    # set the new instance of Chrome to be headless, no-GUI
    options.add_argument("--headless=new")

    # ignore SSL certificate errors, since the Verizon device uses a
    # self signed certificate
    options.add_argument("--ignore-certificate-errors")

    # set the window size to a reasonable size for screenshots and
    # rendering the modals.
    options.add_argument("--window-size=1920,1200")

    # create the Chrome instance
    driver = webdriver.Chrome(options=options)

    # have the headless Chrome fetch the specific URL
    driver.get(url_to_render)

    # wait for it to finish loading. I know there's are more elegant ways
    # to poll/wait for the site to finish loading, but I don't really care
    # for this simple use case. It's just a very simple LAN site.
    sleep(3)

    # what the HTML looks like for the password field and submit button
    # <input type="password" id="password" maxlength="20" name="password"
    #   value="" class="input_type_sign"><a class="btn_type_sign"
    #   href="javascript:void(0);" id="btn_login"><span>Sign In</span></a>

    # find and fill in the password field
    driver.find_element(By.ID, 'password').send_keys(password_to_use)

    # click the sign in button
    driver.find_element(By.ID, 'btn_login').click()

    # wait for it to finish loading
    sleep(3)

    # navigate to the page with the soft reboot button
    driver.get('https://10.0.1.19/#settings/reset')
    # wait for it to finish loading
    sleep(3)

    # find and click the first (warning) button to restart
    # this causes a modal to pop-up in the existing URL that warns the user
    # and confirms that they want to reboot.
    driver.find_element(By.ID, 'btn_complete_restart').click()

    # wait for the modal to load
    sleep(5)

    # find the final reboot button but don't click it yet.
    # this one has a NAME but not an ID.
    reboot_button_confirm = driver.find_element(By.NAME, 'box_ok')
    # print ("found the final reboot button")

    # do any debugging here, used to take screenshots for debugging.
    # screenshot_output_file='screenshot.png'
    # driver.save_screenshot(screenshot_output_file)
    # driver.get_screenshot_as_png()

    # click the final reboot button
    reboot_button_confirm.click()
    print("rebooting now...")

    # for some reason, you do have to wait a moment before exiting the browser
    sleep(5)

    # properly clean up the Chrome instance
    driver.quit()


if __name__ == "__main__":
    main()
