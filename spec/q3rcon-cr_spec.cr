require "./spec_helper"
require "../src/q3rcon"

describe Q3Rcon do
  it "has a version" do
    Q3Rcon::VERSION.should_not be_nil
  end
end
