Given(/^onceover executable$/) do
  @cmd = Command_Helper.new
end

Given(/^control repo "([^"]*)"$/) do |controlrepo_name|
  @repo = ControlRepo_Helper.new( controlrepo_name )
  @cmd.controlrepo = @repo
  FileUtils.rm_rf @repo.root_folder
  FileUtils.mkdir_p @repo.tmp_folder
  FileUtils.cp_r "spec/fixtures/controlrepos/#{controlrepo_name}", @repo.tmp_folder
end

Given(/^existing control repo "([^"]*)"$/) do |controlrepo_name|
  @repo = ControlRepo_Helper.new( controlrepo_name )
  @cmd.controlrepo = @repo
end

Given(/^initialized control repo "([^"]*)"$/) do |controlrepo_name|
  step %Q(control repo "#{controlrepo_name}")
  step %Q(I run onceover command "init")
end

Given(/^control repo "([^"]*)" without "([^"]*)"$/) do |controlrepo_name, filename|
  step %Q(control repo "#{controlrepo_name}")
  FileUtils.rm_rf "#{@repo.root_folder}/#{filename}"
end

When(/^I run onceover command "([^"]*)"$/)  do |command|
  @cmd.command = command
  puts @cmd
  @cmd.run
end

Then(/^I see help for commands: "([^"]*)"$/) do |commands|
  # Get chunk of output between COMMANDS and OPTION, there should be help section
  commands_help = @cmd.output[/COMMANDS(.*)OPTIONS/m, 1]
  commands.split(',').each do |command|
    result = commands_help.match(/^\s+#{command.strip}.+\n/)
    puts result.to_s if expect(result).not_to be nil
  end
end

Then(/^I should not see any errors$/) do
  puts @cmd.output unless @cmd.success?
  expect(@cmd.success?).to be true
end

Then(/^I should see error with message pattern "([^"]*)"$/) do |err_msg_regexp|
  expect(@cmd.success?).to be false
  puts @cmd.output
  expect(@cmd.output.match err_msg_regexp).to_not be nil
end

Then(/^I should see message pattern "([^"]*)"$/) do |err_msg_regexp|
  expect(@cmd.success?).to be true
  puts @cmd.output unless @cmd.output =~ Regexp.new(err_msg_regexp)
  expect(@cmd.output).to match(err_msg_regexp)
  puts @cmd.output.match(err_msg_regexp).to_s
end
