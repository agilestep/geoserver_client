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

end