require 'spec_helper'
require 'geoserver_client'

describe GeoserverClient  do

  context "logger" do
    context "if not set" do
      it "returns nil" do
        expect(GeoserverClient.logger).to eq(nil)
      end
    end
    context "when set" do
      before do
        GeoserverClient.logger = :stdout
      end
      it "remembers the setting" do
        expect(GeoserverClient.logger).to eq(:stdout)
      end
    end
  end

  [[:api_root, "", "http://localhost:8080/"], [:api_password, "geoserver", "other_password"], [:api_user, "admin", "other_user"]].each do |method|
    describe "#{method[0]}" do
      it "returns <#{method[1]}> by default" do
        GeoserverClient.send("#{method[0]}=", nil)
        expect(GeoserverClient.send(method[0])).to eq(method[1])
      end
      it "returns what is set before" do
        GeoserverClient.send("#{method[0]}=", method[2])
        expect(GeoserverClient.send(method[0])).to eq(method[2])
      end
    end
  end

end