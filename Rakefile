require 'cucumber'
require 'cucumber/rake/task'

namespace :jenkins do

  task :full_with_rerun do
    rerun = 'rerun.txt'
    FileUtils.rm_f rerun if File.exist?(rerun)
    begin
      Rake::Task['jenkins:full_suite'].invoke
    rescue Exception => e
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)
        Rake::Task['jenkins:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
      end
    end
  end

  task :smoke_with_rerun do
    rerun = 'rerun.txt'
    FileUtils.rm_f rerun if File.exist?(rerun)
    begin
      Rake::Task['jenkins:smoke_suite'].invoke
    rescue Exception => e
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)
        Rake::Task['jenkins:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
      end
    end
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = 'features --order random -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r features --format json -o cucumber.json'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = 'features --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r features --format json -o cucumber.json -b'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -b --expand -r features --format json -o cucumber.json -b --strict'
  end

end

namespace :vagrant do

  task :full_with_rerun do
    rerun = 'rerun.txt'
    FileUtils.rm_f rerun if File.exist?(rerun)
    begin
      Rake::Task['vagrant:full_suite'].invoke
    rescue Exception => e
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)
        Rake::Task['vagrant:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
      end
    end
  end

  task :smoke_with_rerun do
    rerun = 'rerun.txt'
    FileUtils.rm_f rerun if File.exist?(rerun)
    begin
      Rake::Task['vagrant:smoke_suite'].invoke
    rescue Exception => e
      if File.exist?(rerun)
        rerun_features = IO.read(rerun)

        # DEBUG
        puts
        puts 'In the rescue clause...'
        puts
        puts rerun_features
        puts

        Rake::Task['vagrant:rerun_failed'].invoke unless rerun_features.to_s.strip.empty?
      end
    end
  end

  Cucumber::Rake::Task.new(:test) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t @test --format rerun --out rerun.txt --expand -r /kuality-coeus/features'
  end

  Cucumber::Rake::Task.new(:full_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features -b -t ~@wip -t ~@smoke -t ~@performance -t ~@system_failure --format rerun --out rerun.txt --expand -r /kuality-coeus/features'
  end

  Cucumber::Rake::Task.new(:smoke_suite) do |t|
    t.cucumber_opts = '/kuality-coeus/features --verbose --expand -t @smoke -t ~@wip -t ~@system_failure --format rerun --out rerun.txt -r /kuality-coeus/features'
  end

  Cucumber::Rake::Task.new(:rerun_failed) do |t|
    t.cucumber_opts = '@rerun.txt -r /kuality-coeus/features -b --expand --verbose --strict --format json -o cucumber.json'
  end

end