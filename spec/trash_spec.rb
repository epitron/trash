require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Trash" do
  test_files = [
    "/tmp/testing.txt",
    "/tmp/testing2.txt"
  ]
  trash_files = [
    "/Users/leejones/.Trash/testing.txt",
    "/Users/leejones/.Trash/testing2.txt",
    "/Users/leejones/.Trash/testing01.txt",
    "/Users/leejones/.Trash/testing02.txt",
    "/Users/leejones/.Trash/testing03.txt",
    "/Users/leejones/.Trash/testdir01",
    "/Users/leejones/.Trash/testdir02"
  ]
    
  before do
    test_files.each {|f| `echo 'default text' > #{f}`}
  end
  
  after do
    trash_files.each {|f| delete(f)}
  end
  
  def delete(file)
    `if [ -e #{file} ]; then rm -rf #{file}; fi;`
  end

  def trash_should_contain(file_name)
    File.exist?("#{ENV['HOME']}/.Trash/#{file_name}").should == true    
  end

  def trash_should_contain_directory(directory_name)
    File.directory?(directory_name)
    trash_should_contain(directory_name)
  end
  
  def tmp_should_not_contain(file_name)
    File.exist?("/tmp/#{file_name}").should == false
  end

  it "moves a file to the trash" do
    Trash.throw_out("/tmp/testing.txt")
    tmp_should_not_contain "testing.txt"
    trash_should_contain "testing.txt"
  end
  
  it "moves multiple files to the trash" do
    Trash.throw_out("/tmp/testing.txt /tmp/testing2.txt")
    tmp_should_not_contain "testing.txt"
    tmp_should_not_contain "testing2.txt"
    trash_should_contain "testing.txt"
    trash_should_contain "testing2.txt"
  end

  it "appends a number to the filename if a file with same name already exisits in trash" do
    Trash.throw_out("/tmp/testing.txt")
    tmp_should_not_contain "testing.txt"
    trash_should_contain "testing.txt"
    original = File.new("/Users/leejones/.Trash/testing.txt", "r")
    original.read.should == "default text\n"
    
    `echo 'testing different file with same name' > /tmp/testing.txt`
    Trash.throw_out("/tmp/testing.txt")
    tmp_should_not_contain "testing.txt"
    trash_should_contain "testing01.txt" 
    third = File.new("/Users/leejones/.Trash/testing01.txt", "r")
    third.read.should == "testing different file with same name\n"
  
    `echo 'testing different file 2 with same name' > /tmp/testing.txt`
    Trash.throw_out("/tmp/testing.txt")
    tmp_should_not_contain "testing.txt"
    trash_should_contain "testing02.txt"
    fourth = File.new("/Users/leejones/.Trash/testing02.txt", "r")
    fourth.read.should == "testing different file 2 with same name\n"

    `echo 'testing different file 3 with same name' > /tmp/testing.txt`
    Trash.throw_out("/tmp/testing.txt")
    tmp_should_not_contain "testing.txt"
    trash_should_contain "testing03.txt"
    fifth = File.new("/Users/leejones/.Trash/testing03.txt", "r")
    fifth.read.should == "testing different file 3 with same name\n"
  end
  
  it "moves a directory to the trash" do
    dir = `mkdir -p /tmp/testdir01`
    Trash.throw_out("/tmp/testdir01")
    tmp_should_not_contain "testdir01"
    trash_should_contain_directory "testdir01"
  end

  it "moves multiple directories to the trash" do
    dirs = `mkdir -p /tmp/testdir01 /tmp/testdir02`
    Trash.throw_out("/tmp/testdir01 /tmp/testdir02")
    tmp_should_not_contain "testdir01"
    tmp_should_not_contain "testdir02"
    trash_should_contain_directory "testdir01"
    trash_should_contain_directory "testdir02"
  end

  it "finds the trashcan" do
    Trash.has_trashcan?.should == true
  end
end
