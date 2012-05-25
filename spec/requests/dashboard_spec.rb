require 'shared_context/capybara_url_options'
require 'spec_helper'

describe "Dashboard" do
  include_context 'capybara url options'
  before(:all) do
    @user = FactoryGirl.create(:user)
  end

  before(:each) do
    @user.reload
    DashboardController.any_instance.stub(:current_user).and_return(@user)
    UserHashtagsController.any_instance.stub(:current_user).and_return(@user)
  end

  def underlying_checkbox(element)
    element.find('input[type="checkbox"]')
  end

  def page_has_selectors(selectors)
    selectors.each do |selector, visible|
      page.should have_selector(selector, :visible => visible)
    end
  end

  describe "GET /dashboard" do
    it "has links to Blastout, Mashout, and Shoutout" do
      [['Blastout', dashboard_blastout_path], ['Mashout', dashboard_mashout_path], ['Shoutout', dashboard_shoutout_path]].each do |action, path|
        visit dashboard_path

        link = find_link(action.upcase)
        link.should be
        link.click

        page.current_path.should == path
      end
    end

    it "has a dropdown allowing users to get to the tools" do
      visit dashboard_path
      page.has_select?('tool', :with_options => ['BLASTOUT', 'MASHOUT', 'SHOUTOUT'])
    end
  end

  describe "GET /dashboard/blastout" do
    before(:all) do
      @videos = (0..4).map {|n| FactoryGirl.create(:video, :user => @user) }.reverse
    end

    before(:each) do
      visit dashboard_blastout_path
    end

    context 'add a video' do
      it 'should have visible radio buttons for videos on this page' do
        @videos[0...4].each do |video|
          find("#video-#{video.guid}").should be_visible
        end
      end

      it 'should update the out preview when a video is chosen', :js => true do
        video = @videos.first

        find('#out-preview').value.should == ''
        find("#video-#{video.guid}").click
        find('#out-preview').value.should == video.bitly_uri
      end

      it 'should update the out preview when the user switches videos', :js => true do
        find('#out-preview').value.should == ''
        find("#video-#{@videos.first.guid}").click
        find('#out-preview').value.should == @videos.first.bitly_uri
        find("#video-#{@videos.second.guid}").click
        find('#out-preview').value.should == @videos.second.bitly_uri
      end

      it 'should have pagination' do
        page.should have_css('#videos .pagination')
        within('#videos .pagination') do
          page.should have_link('2')
        end
      end

      it 'should paginate properly', :js => true do
        last_video = @videos.last

        page.should_not have_css("#video-#{last_video.guid}")
        within('#videos .pagination') do
          find_link('2').click
        end
        page.should have_css("#video-#{last_video.guid}")
      end
    end

    context 'add a target' do
      context 'from dropdown' do
        it 'should have a targets dropdown' do
          page.has_select?('#mashout-target-selection',
                           :with_options => ['Tweople', 'Follower Tweeps', 'Tweeps',
                                             'I Follow', 'Mentions', "#RT's", 'Besties', 'Celeb'])
        end
      end

      context 'from media icons' do
        it 'should not display hidden icons on page load' do
          page.should have_selector('#hidden-media-icons', :visible => false)
        end

        it 'should display hidden icons when Show More is clicked', :js => true do
          within('#media-icons') do
            click_link('Show More')
            page.should have_selector('#less-media', :visible => true)
            page.should have_selector('#more-media', :visible => false)
          end
          page.should have_selector('#hidden-media-icons', :visible => true)
        end

        context 'on click', :js => true do
          before(:each) do
            @icons = all('#media-icons li')
            @icon = @icons.first
            @icon.click
          end

          it 'should turn the icon "on"' do
            @icon[:class].should =~ /on/
          end

          it 'should turn the icon "off" if clicked again' do
            @icon.click
            @icon[:class].should_not =~ /on/
          end

          it 'should check the underlying checkbox' do
            underlying_checkbox(@icon).should be_checked
          end

          it 'should uncheck the underlying checkbox if clicked again' do
            @icon.click
            underlying_checkbox(@icon).should_not be_checked
          end

          it 'should add the media target to the out preview' do
            find('#out-preview').value.should == underlying_checkbox(@icon).value
          end

          it 'should remove the media target if clicked again' do
            @icon.click
            find('#out-preview').value.should be_empty
          end

          it 'should handle multiple icons correctly' do
            first_icon   = @icon
            first_check  = underlying_checkbox(first_icon)
            second_icon  = @icons.second
            second_check = underlying_checkbox(second_icon)

            find('#out-preview').value.should == first_check.value
            second_icon.click
            second_check.should be_checked
            find('#out-preview').value.should == "#{first_check.value} #{second_check.value}"
            first_icon.click
            first_check.should_not be_checked
            find('#out-preview').value.should == second_check.value
          end
        end
      end
    end

    context 'add a hashtag', :js => true do
      before(:each) do
        @hashtags = all('#mashout-hashtag-checkboxes ul')
      end

      it 'should handle a single hashtag correctly' do
        checkbox = underlying_checkbox(@hashtags.first)

        checkbox.click
        find('#out-preview').value.should == checkbox.value
        checkbox.click
        find('#out-preview').value.should be_empty
      end

      it 'should handle multiple hashtags correctly' do
        hashtags   = @hashtags.take(3)
        checkboxes = hashtags.map { |tag| underlying_checkbox(tag) }

        checkboxes.each { |checkbox| checkbox.click }
        find('#out-preview').value.should == checkboxes.map { |checkbox| checkbox.value }.join(' ')

        checkboxes.first.click
        find('#out-preview').value.should == "#{checkboxes[1].value} #{checkboxes[2].value}"
      end

      context 'edit a hashtag' do
        before(:each) do
          @hashtag   = @hashtags.first
          @checkbox  = underlying_checkbox(@hashtag)
          @container = "##{@checkbox[:id]}-container"
          @label     = "##{@checkbox[:id]}-label"
          @text      = "##{@checkbox[:id]}-text"
          @edit      = "##{@checkbox[:id]}-edit"
          @confirm   = "##{@checkbox[:id]}-confirm"
          @cancel    = "##{@checkbox[:id]}-cancel"
          @delete    = "##{@checkbox[:id]}-delete"
        end

        it 'should show just the edit and delete icons' do
          selectors = { @label   => true,
                        @edit    => true,
                        @delete  => true,
                        @cancel  => false,
                        @confirm => false,
                        @text    => false }
          page_has_selectors(selectors)
        end

        it 'should create the editing environment when the edit button is clicked' do
          find(@edit).click
          selectors = { @label   => false,
                        @edit    => false,
                        @text    => true,
                        @confirm => true,
                        @cancel  => true,
                        @delete  => true }
          page_has_selectors(selectors)
        end

        it "should tear down edit environment when cancel is clicked" do
          find(@edit).click
          find(@cancel).click
          selectors = { @text    => false,
                        @confirm => false,
                        @cancel  => false,
                        @label   => true,
                        @edit    => true,
                        @delete  => true }
          page_has_selectors(selectors)
        end

        it 'should handle editing a hashtag correctly' do
          find(@edit).click
          fill_in(@text[1..-1], :with => '#newhash')
          find(@confirm).click
          wait_until { page.find('#mashout-newhash-hashtag') }
          find('#mashout-newhash-hashtag').value.should == '#newhash'
        end

        it 'should handle invalid hashtags correctly' do
          find(@edit).click
          fill_in(@text[1..-1], :with => 'invalid#hash')
          find(@confirm).click
          wait_until { page.find(@container + ' p') }
          find(@container).find('p').should have_content('valid hashtag')
        end

        it 'should handle cancelling an edit correctly' do
          find(@edit).click
          fill_in(@text[1..-1], :with => '#newhash')
          find(@cancel).click
          find(@text).value.should == @checkbox.value
          find(@label).text.should == @checkbox.value
        end
      end
    end
  end
end
