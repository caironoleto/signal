require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Build do
  should_belong_to :project
  should_validate_presence_of :project, :output, :commit, :author, :comment
  it_should_behave_like 'statusable'

  context "on creation" do
    before :each do
      fail_on_command
      @project = Factory.build :project, :branch => "staging"
      @another_project = Factory.build :project, :branch => "staging", :bundle_install => false, :continuous_deployment => true
      system "echo \"lorem ipsum\" > tmp/#{@project.name}"
      build_repo_for @project
    end

    it "should pull the repository from the project url and branch" do
      expect_for "cd #{@project.send :path} && git pull #{@project.url} #{@project.branch} > #{@project.send :log_path} 2>&1"
      Build.create! :project => @project
    end

    it "should execute bundle install before build" do
      expect_for "cd #{@project.send :path} && bundle install --path .gems >> #{@project.send :log_path} 2>&1"
      Build.create! :project => @project
    end

    it "should not execute bundle install before build" do
      dont_accept "cd #{@another_project.send :path} && bundle install --path .gems >> #{@another_project.send :log_path} 2>&1"
      Build.create! :project => @another_project
    end

    it "should use the project gemset" do
      expect_for "cd #{@project.send :path} && rvm gemset use #{@project.name} >> #{@project.send :log_path} 2>&1"
      Build.create! :project => @project
    end

    it "should build the project unsetting GEM_PATH, RUBYOPT, RAILS_ENV, BUNDLE_GEMFILE and executing the project's build command" do
      @project.build_command = "rake test"
      expect_for "cd #{@project.send :path} && unset GEM_PATH && unset RUBYOPT && unset RAILS_ENV && unset BUNDLE_GEMFILE && rake test >> #{@project.send :log_path} 2>&1"
      Build.create! :project => @project
    end

    it "should build the project with a clean Bundler env" do
      Bundler.should_receive(:with_clean_env).and_yield
      Build.create! :project => @project
    end

    it "should save the log" do
      log = "Can't touch this!"
      File.stub!(:open).with(@project.send :log_path).and_return(mock(Object, :read => log))
      Build.create!(:project => @project).output.should eql(log)
    end

    it "should determine if the build was a success or not" do
      fail_on_command
      Build.create!(:project => @project).success.should be_false
    end

    it "should not deliver a fail notification email when build don't fail" do
      success_on_command
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fail_notification).with(build)
      build.save
    end

    it "should deliver an fail notification email if build fails" do
      fail_on_command
      build = Build.new :project => @project
      Notifier.should_receive(:fail_notification).with(build).and_return(notifier = mock(Notifier))
      notifier.should_receive :deliver
      build.save
    end

    it "should deliver a fix notification email if build success and last build failed" do
      success_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.should_receive(:fix_notification).with(build).and_return(notifier = mock(Notifier))
      notifier.should_receive :deliver
      build.save
    end

    it "should not deliver a fix notification email if build success and last build successed" do
      success_on_command
      Build.stub!(:last).and_return(mock(Build, :success => true))
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fix_notification).with(build)
      build.save
    end

    it "should not deliver a fix notification email if build fail and last build failed" do
      fail_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fix_notification).with(build)
      build.save
    end

    it "should not deliver a fix notification email if build fail and last build successed" do
      fail_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fix_notification).with(build)
      build.save
    end

    it "should not deploy after a success build" do
      success_on_command
      dont_accept "cd #{@project.send :path} && #{@project.deploy_command} > #{@project.send :log_path} 2>&1"
      Build.create! :project => @project
    end

    it "should deploy after a success build" do
      success_on_command
      expect_for "cd #{@another_project.send :path} && #{@another_project.deploy_command} > #{@another_project.send :log_path} 2>&1"
      Build.create! :project => @another_project
    end

    it "should save the author of the commit that forced the build" do
      Build.create!(:project => @project).author.should eql(@author)
    end

    it "should save the hash of the commit that forced the build" do
      Build.create!(:project => @project).commit.should eql(@commit)
    end

    it "should save the comment of the commit that forced the build" do
      Build.create!(:project => @project).comment.should eql(@comment)
    end
  end
end
