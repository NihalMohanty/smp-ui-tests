g_device = ""

Given(/^I visit "([^"]*)" with a "([^"]*)" player on "([^"]*)"$/) do |new_page, new_type, new_device|
  visit( new_page )
  g_device = new_device
  sleep(1)
  if g_device == "phone"
      if page.driver.browser.browser == :firefox
        # If it is a PHONE and FIREFOX browser we skip as it's not used by anybody!
        # This will mark the step as yellow in Terminal output
        pending
      else
        page.driver.browser.manage.window.resize_to( 300 , 1800 )
      end
  elsif g_device == "tablet"
    page.driver.browser.manage.window.resize_to( 1000 , 1000 )
  else
    page.driver.browser.manage.window.resize_to( 1800 , 1480 )
  end
  # If webcast we need to set some data first for seekbar to show
  if new_type == "webcast"
    page.first("#setWebcastData").click
    sleep(1)
  end
  sleep(1)
end

Given(/^I am on a page with the HTML player and quality settings set to true$/) do
  visit('https://is.gd/idiseq')
end

When(/^the COOKBOOK has loaded$/) do
  if page.driver.browser.browser == :safari
    # Do nothing as safari cannot see the h1
    sleep(2)
  else
    find( "h1" , text: "SMP COOKBOOK" )
    sleep(2)
  end
  find( "h1" , text: "SMP COOKBOOK" )
  sleep(2)
end

When(/^I click CTA to begin playback$/) do
  within_frame 'smphtml5iframemp' do
    page.first("div.p_accessibleHitArea").click
    sleep(2)
    # If its the video player we need to re-focus on player after pressing CTA, Jim made a change!
    if page.has_css?('#p_v_player_0') == true
      find('#p_v_player_0').hover
    end
  end
end

When(/^I replay if "([^"]*)"$/) do |type|
  within_frame 'smphtml5iframemp' do
    if type == "simulcast" or type == "webcast"
      # Do nothing as we cannot replay simulcast or webcast
    else
      page.first("div.p_accessibleHitArea").click
      sleep(2)
      if page.has_css?('#p_v_player_0') == true
        find('#p_v_player_0').hover
      end
    end
  end
end

Then(/^I can pause$/) do
  within_frame 'smphtml5iframemp' do
    sleep(1)
    page.first(".p_pauseIcon").click
  end
end

Then(/^I can play$/) do
  within_frame 'smphtml5iframemp' do
    sleep(1)
    page.first(".p_playIcon").click
  end
end

Then(/^I can mute$/) do
  within_frame 'smphtml5iframemp' do
    # Smaller windows have mute icon hidden
    if g_device == "desktop"
      sleep(1)
      page.first(".p_volumeButton").click
    end
  end
end

Then(/^I can unmute$/) do
  within_frame 'smphtml5iframemp' do
    # Smaller windows have mute icon hidden
    if g_device == "desktop"
      sleep(1)
      page.first(".p_volumeButton").click
    end
  end
end

Then("I can click each volume bar") do
  within_frame 'smphtml5iframemp' do
    sleep(1)
    page.first(".p_volumeButton").hover
    page.all(:css, '.p_volumeBar').each do |item|
      item.click
    end
  end
end

When(/^I can enter fullscreen if "([^"]*)"$/) do |type|
  # If it's any type of video
  if type != "minimode"
    within_frame 'smphtml5iframemp' do
      sleep(2)
      page.first(".p_fullscreenButton").click
      sleep(2)
      # If its not 360 we re-apply focus to the player because of Jim change
      if type != "360" and type != "audio"
        find('#p_v_player_0').hover
      end
    end
  end
end

When(/^I can exit fullscreen if "([^"]*)"$/) do |type|
  if type != "audio" and type != "minimode" or type != "360"
    within_frame 'smphtml5iframemp' do
      sleep(2)
      page.first(".p_fullscreen-returnIcon").click
      sleep(2)
    end
  end
end

When("I can double click anywhere in the player hitbox to enter fullscreen") do
  within_frame 'smphtml5iframemp' do
    if page.has_css?('#p_v_player_0') == true
      find('#p_v_player_0').hover
    end
    sleep(2)
    page.first('#p_v_player_0').double_click
  end
end

When("I can double click anywhere in the player hitbox to exit fullscreen") do
  within_frame 'smphtml5iframemp' do
    if page.has_css?('#p_v_player_0') == true
      find('#p_v_player_0').hover
    end
    sleep(2)
    page.first('#p_v_player_0').double_click
    sleep(1)
    find('#p_v_player_0').hover
  end
end

Then(/^I can interact with subtitles panel if "([^"]*)"$/) do |type|
  within_frame 'smphtml5iframemp' do
    if type == "ident + vod + subs"
      # Click SUBS button to see current status + turn s
      page.first(".p_subtitleButton").click
      sleep(1)

      if page.driver.browser.browser == :chrome
        # Chrome needs an additional press for some reason
        sleep(1)
        page.first(".p_subsToggle").click
        sleep(1)
        page.first(".p_subtitleButton").click
      end

      sleep(1)
      page.first("#p_subtitleSizeButton_useSmallestFontSize").click
      sleep(1)
      expect(page.find('button#p_subtitleSizeButton_useSmallestFontSize')['aria-pressed']).to eq("true")
      sleep(1)
      page.first("#p_subtitleSizeButton_useSmallFontSize").click
      expect(page.find('button#p_subtitleSizeButton_useSmallFontSize')['aria-pressed']).to eq("true")
      sleep(1)
      page.first("#p_subtitleSizeButton_useMediumFontSize").click
      expect(page.find('button#p_subtitleSizeButton_useMediumFontSize')['aria-pressed']).to eq("true")
      sleep(1)
      page.first("#p_subtitleSizeButton_useLargeFontSize").click
      expect(page.find('button#p_subtitleSizeButton_useLargeFontSize')['aria-pressed']).to eq("true")
      sleep(1)
      page.first("#p_subtitleSizeButton_useLargestFontSize").click
      expect(page.find('button#p_subtitleSizeButton_useLargestFontSize')['aria-pressed']).to eq("true")
    end
  end
end

Then(/^I can change subtitles font size if "([^"]*)"$/) do |type|
  within_frame 'smphtml5iframemp' do
    if (type == "ident + vod + subs" and g_device == "desktop")
      # Click SUBS button to see current status
      page.first("button.p_subtitleButton").click

      sleep(1)
      page.first(".p_subtitleButton").click

      sleep(1)
      page.first("#p_subtitleSizeButton_useSmallestFontSize").click

      sleep(2)
      hash1 = page.find('div.p_subtitlesContainer div.p_paragraph').style('width')
      page.first("#p_subtitleSizeButton_useLargestFontSize").click

      sleep(1)
      hash2 = page.find('div.p_subtitlesContainer div.p_paragraph').style('width')
      expect(hash1["width"] < hash2["width"]).to be true
    end
  end
end

Then(/^I can click seekbar unless "([^"]*)"$/) do |type|
  within_frame 'smphtml5iframemp' do
    if (type == "simulcast" and g_device == "tablet") or (type == "simulcast" and g_device == "desktop")
      page.first(".p_chapterMarker").click
      page.first(".p_chapterMarker").hover
    elsif type == "simulcast" and g_device == "phone"
      page.should have_no_selector(".p_chapterMarker")
      page.first(".p_progressBar").click
      page.first(".p_progressBar").hover
    elsif type == "webcast"
      page.first(".p_progressBar").click
      page.first(".p_progressBar").hover
    else
      page.first(".p_seekBar").click
      page.first(".p_seekBar").hover
    end
  end
end

Then(/^I can click seekbar in fullscreen "([^"]*)"$/) do |type|
  if type != "minimode"
    within_frame 'smphtml5iframemp' do
      sleep(2)
      page.first(".p_playerSeekBarHolder").click
      sleep(1)
      page.first(".p_playerSeekBarHolder").hover
    end
  end
end
