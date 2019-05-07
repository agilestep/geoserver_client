# configure geoserver-client
require "base64"
require "json"
require_relative '../lib/geoserver_client'

GeoserverClient.api_root     = "http://localhost:8080/geoserver/rest/"
GeoserverClient.api_user     = "admin"
GeoserverClient.api_password = "YOUR_SECRET_PASSWORD"

GeoserverClient.workspace    = 'YOUR_WORKSPACE'
GeoserverClient.datastore    = 'YOUR_DATASTORE'

GeoserverClient.logger = :stdout


# puts GeoserverClient.delete_layergroup("masterdata_2", true)
# puts GeoserverClient.create_layergroup("masterdata_2", ["sabic:pipelines", "sabic:cables"], {}, true)
#
# puts GeoserverClient.layergroups(true)
#
# puts GeoserverClient.get_layergroup("masterdata", true )
#
# puts GeoserverClient.layergroups(true)
#
# puts GeoserverClient.delete_layergroup("masterdata", true)
# puts GeoserverClient.delete_layergroup("masterdata_2", true)
#


# create an sld for test

welds_sld = <<-SLD
<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0" 
 xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" 
 xmlns="http://www.opengis.net/sld" 
 xmlns:ogc="http://www.opengis.net/ogc" 
 xmlns:xlink="http://www.w3.org/1999/xlink" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <!-- a Named Layer is the basic building block of an SLD document -->
  <NamedLayer>
    <Name>default_point</Name>
    <UserStyle>
    <!-- Styles can have names, titles and abstracts -->
      <Title>Default Point</Title>
      <Abstract>A sample style that draws a point</Abstract>
      <!-- FeatureTypeStyles describe how to render different features -->
      <!-- A FeatureTypeStyle for rendering points -->
      <FeatureTypeStyle>
        <Rule>
          <Name>rule1</Name>
          <Title>Green circle</Title>
          <Abstract>A 6 pixel circle with a red fill and no stroke</Abstract>
          <MinScaleDenominator>1000</MinScaleDenominator>
          <MaxScaleDenominator>2500</MaxScaleDenominator>
          <PointSymbolizer>
            <Graphic>
              <Mark>
                <WellKnownName>circle</WellKnownName>
                <Fill>
                  <CssParameter name="fill">#00FF00</CssParameter>
                </Fill>
              </Mark>
              <Size>6</Size>
            </Graphic>
          </PointSymbolizer>
        </Rule>
        <Rule>
          <Name>rule2</Name>
          <Title>Green circle with label</Title>
          <Abstract>A 6 pixel circle with a red fill and no stroke, and a label</Abstract>
          <MaxScaleDenominator>1000</MaxScaleDenominator>
          <PointSymbolizer>
            <Graphic>
              <Mark>
                <WellKnownName>circle</WellKnownName>
                <Fill>
                  <CssParameter name="fill">#00FF00</CssParameter>
                </Fill>
              </Mark>
              <Size>6</Size>
            </Graphic>
          </PointSymbolizer>
          <TextSymbolizer>
            <Label>
              <ogc:PropertyName>name</ogc:PropertyName>
            </Label>
            <Font>
              <CssParameter name="font-family">Arial</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-style">normal</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <LabelPlacement>
              <PointPlacement>
                <AnchorPoint>
                  <AnchorPointX>0.1</AnchorPointX>
                  <AnchorPointY>0.0</AnchorPointY>
                </AnchorPoint>
                <Displacement>
                  <DisplacementX>0</DisplacementX>
                  <DisplacementY>5</DisplacementY>
                </Displacement>
                <Rotation>-45</Rotation>
              </PointPlacement>
            </LabelPlacement>
            <Fill>
              <CssParameter name="fill">#000000</CssParameter>
            </Fill>
            <VendorOption name="conflictResolution">false</VendorOption>   
            <VendorOption name="partials">true</VendorOption>
          </TextSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>

SLD


# Lets assume we have a table called welds in the datastore and create a layer for it

puts GeoserverClient.delete_style("test_welds", true )
puts GeoserverClient.delete_featuretype("test_welds", true )

puts GeoserverClient.create_style("test_welds", {sld: welds_sld}, true )
puts GeoserverClient.create_featuretype("test_welds", {style_name: "test_welds", native_name: "welds"}, true)
# puts GeoserverClient.set_layer_style("test_welds", {style_name: "test_welds", native_name: "welds"}, true)

# puts GeoserverClient.delete_style("heli_trees")


file_name = File.join(File.expand_path(File.dirname(__FILE__)), "rapl_zakbaken_s.png")
puts GeoserverClient.create_resource(file_name)
# puts GeoserverClient.delete_resource(file_name)