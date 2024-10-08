require 'httpclient'
require 'httpclient/include_client'


class GeoserverClient

  extend HTTPClient::IncludeClient
  include_http_client do |client|
    client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end


  class ConfigException < StandardError

  end

  def self.api_user
    @@api_user ||= "admin"
  end

  def self.api_password
    @@api_password ||= "geoserver"
  end

  def self.api_root
    @@api_root ||= ""
  end

  def self.api_user=(api_user)
    @@api_user = api_user
  end

  def self.api_password=(api_password)
    @@api_password = api_password
  end

  def self.api_root= (api_root)
    api_root += "/" if !api_root.nil? && api_root[-1] != "/"
    @@api_root = api_root
  end

  def self.workspace
    raise ConfigException.new('GeoserverClient::workspace is not yet set') if @@default_workspace.nil?
    @@default_workspace
  end

  def self.datastore
    raise ConfigException.new('GeoserverClient::datastore is not yet set') if @@default_datastore.nil?
    @@default_datastore
  end

  def self.workspace=(other_workspace)
    @@default_workspace = other_workspace
  end

  def self.datastore=(other_datastore)
    @@default_datastore = other_datastore
  end

  def self.logger
    @@logger rescue nil 
  end

  def self.logger=(other_logger)
    @@logger = other_logger
  end

  def self.log(message, loglevel=:debug )
    return if logger.nil?
    if logger.respond_to?(loglevel)
      logger.send loglevel, "GeoserverClient::#{message}"
    elsif logger == :stdout
      puts message
    end
  end



  def self.all_layer_names(debug_mode=false)
    all_layers_data = self.all_layers(debug_mode)
    all_layers_data["featureTypes"]["featureType"].map{|x| x["name"]}
  end


  def self.all_layers(debug_mode=false)
    log "Get all layers in workspace #{self.workspace}"

    puts "workspace = #{self.workspace}"

    get_feature_types_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/featuretypes" )
    get_data(get_feature_types_uri, {}, debug_mode )
  end


  def self.layers(debug_mode=false)
    log "Get layers in datastore #{self.datastore}"

    get_feature_types_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/datastores/#{self.datastore}/featuretypes" )
    get_data(get_feature_types_uri, {}, debug_mode )
  end

  def self.feature_type(layer_name, debug_mode=false)
    log "Get layer #{layer_name} in datastore #{self.datastore}"

    get_feature_type_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/datastores/#{self.datastore}/featuretypes/#{layer_name}" )
    get_data(get_feature_type_uri, {}, debug_mode )
  end

  def self.layer(layer_name, debug_mode=false)
    log "Get layer #{layer_name} in datastore #{self.datastore}"

    get_feature_type_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/datastores/#{self.datastore}/layers/#{layer_name}" )
    get_data(get_feature_type_uri, {}, debug_mode )
  end

  def self.create_featuretype(name, options={}, debug_mode=false)
    data = {
        featureType: {
            name: name,
            nativeName: options[:native_name] || name,
            # title: options[:title],
            # abstract: options[:abstract],
            # store: {
            #     "@class" => "dataStore",
            #     name: self.datastore
            # },
            # projectionPolicy: options[:projection_policy] || "FORCE_DECLARED",
            # srs: options[:srs] || "EPSG:3035",
            # # more options
        }
    }



    create_featuretype_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/datastores/#{self.datastore}/featuretypes" )
    post_data create_featuretype_uri, data.to_json, debug_mode
  end


  def self.delete_featuretype(name, debug_mode=false)
    delete_featuretype_uri = URI.join(GeoserverClient.api_root, "workspaces/#{self.workspace}/datastores/#{self.datastore}/featuretypes/#{name}?recurse=true" )
    response = post_data(delete_featuretype_uri, {}, debug_mode, method: :delete )
  end



  # def self.create_layer(layer_name, options={}, debug_mode=false)
  #   data = {featureType: {
  #       name: layer_name,
  #       native_name: options[:native_name] || layer_name,
  #       title: options[:title],
  #       abstract: options[:abstract],
  #
  #
  #   }}
  #
  #   update_layer_uri = URI.join(GeoserverClient.api_root, "layers/#{self.workspace}:#{layer_name}.json" )
  #   post_data update_layer_uri, data, debug_mode, method: :put
  #
  # end


  def self.set_layer_style(layer_name, style_name, debug_mode=false)
    data = {layer: {defaultStyle: style_name }}

    update_layer_uri = URI.join(GeoserverClient.api_root, "layers/#{self.workspace}:#{layer_name}" )
    post_data update_layer_uri, data.to_json, debug_mode, method: :put
  end

  def self.styles(debug_mode=false)
    log "Geoserver::Get styles in datastore #{self.datastore}"

    get_styles_uri = URI.join(GeoserverClient.api_root, "styles" )
    get_data(get_styles_uri, {}, debug_mode )
  end

  def self.style(style_name, format=:sld, debug_mode=false)
    log "Geoserver::Get styles in datastore #{self.datastore}"

    get_styles_uri = URI.join(GeoserverClient.api_root, "styles/#{style_name}.#{format}" )
    get_data(get_styles_uri, {}, debug_mode )
  end

  def self.create_style(name, options={}, debug_mode=false)
    filename = options[:filename] || "#{name}.sld"

    # raise exception if filename does not end in sld?

    data = { style:
      {
        name: name,
        filename: filename
      }
    }
    create_style_uri = URI.join(GeoserverClient.api_root, "styles" )
    response = post_data(create_style_uri, data.to_json, debug_mode)

    if options[:sld].present?
      post_sld_uri = URI.join(GeoserverClient.api_root, "styles/#{filename}" )
      response = post_data(post_sld_uri, options[:sld], debug_mode, method: :put, content_type: 'application/vnd.ogc.sld+xml')
    end

    response
  end

  def self.update_style(name, options={}, debug_mode=false)
    filename = options[:filename] || "#{name}.sld"

    # raise exception if filename does not end in sld?

    if options[:sld].present?
      post_sld_uri = URI.join(GeoserverClient.api_root, "styles/#{filename}" )
      response = post_data(post_sld_uri, options[:sld], debug_mode, method: :put, content_type: 'application/vnd.ogc.sld+xml')
    else
      raise StandardError.new("SLD parameter was missing!")
    end

    response
  end



  def self.delete_style(name, debug_mode = false)
    delete_style_uri = URI.join(GeoserverClient.api_root, "styles/#{name}" )
    response = post_data(delete_style_uri, {}, debug_mode, method: :delete )
  end


  def self.create_resource(file_name, options={}, debug_mode=false)
    # check if the file exists?
    raise StandardError.new("Given file #{file_name} does not exist?") unless File.exist?(file_name)

    basename  = File.basename(file_name)
    file_data = File.read(file_name)


    create_resource_uri = URI.join(GeoserverClient.api_root, "resource/styles/", basename, "?operation=default" )

    puts "Create resource uri = #{create_resource_uri}"

    response = post_data(create_resource_uri, file_data, debug_mode, method: :put, content_type: '*/*')
    response
  end

  def self.delete_resource(file_name, options={}, debug_mode=false)

    basename  = File.basename(file_name)

    # deleting will delete folder recursively, but how can we check/protect this?

    delete_resource_uri = URI.join(GeoserverClient.api_root, "resource/", basename )

    puts "Delete resource uri = #{delete_resource_uri}"

    response = post_data(delete_resource_uri, {}, debug_mode, method: :delete)
    response
  end


  def self.create_layergroup(layer_group_name, layers, options= {}, debug_mode = false)
    log "Geoserver::Create layer-group #{layer_group_name} in datastore #{self.datastore}"

    data = { layerGroup: {
        name: layer_group_name,
        mode: "SINGLE",
        workspace: { name: GeoserverClient.workspace },
        publishables: {published:[]}
      }
    }

    layers.each do |layer|
      layer_data = {"@type" => "layer", "name" => layer}
      data[:layerGroup][:publishables][:published] << layer_data
    end

    create_layergroup_uri = URI.join(GeoserverClient.api_root, "layergroups" )

    # puts "Create layergroup uri = #{create_layergroup_uri}"

    response = post_data(create_layergroup_uri, data.to_json, debug_mode)
    response
  end

  def self.layergroups(debug_mode=false)
    log "Geoserver::Get layergroups in workspace #{self.workspace}"

    get_layergroups_uri = URI.join(GeoserverClient.api_root, "workspaces/#{GeoserverClient.workspace}/layergroups" )
    get_data(get_layergroups_uri, {}, debug_mode )
  end



  def self.get_layergroup(layer_group_name, debug_mode = false)
    log "Geoserver::Get layer-group #{layer_group_name} in datastore #{self.datastore}"

    get_lg_uri = URI.join(GeoserverClient.api_root, "workspaces/#{GeoserverClient.workspace}/layergroups/#{layer_group_name}" )
    get_data(get_lg_uri, {}, debug_mode )
  end


  def self.delete_layergroup(layer_group_name, debug_mode = false)
    log "Geoserver::DELETE layer-group #{layer_group_name} in workspace #{self.workspace}"

    get_lg_uri = URI.join(GeoserverClient.api_root, "workspaces/#{GeoserverClient.workspace}/layergroups/#{layer_group_name}" )
    post_data(get_lg_uri, {}, debug_mode, method: :delete )
  end


  protected

  def self.get_data(uri, data, debug_mode)
    if debug_mode
      log "URL = #{uri}"
      @debugger = []
      self.http_client.debug_dev = @debugger
    end

    auth = Base64.strict_encode64("#{GeoserverClient.api_user}:#{GeoserverClient.api_password}")
    log "Authorization = #{auth}" if debug_mode

    response = self.http_client.get(uri, data, {'Authorization' => "Basic #{auth}" })

    log @debugger.inspect if debug_mode

    raise StandardError.new(response.body) unless response.status == 200

    JSON.parse(response.body) rescue response.body
  end


  def self.post_data(uri, data, debug_mode, options={})
    http_method = options[:method] || :post
    if debug_mode
      log "URL = #{uri}"
      @debugger = []
      self.http_client.debug_dev = @debugger
    end

    auth = Base64.strict_encode64("#{GeoserverClient.api_user}:#{GeoserverClient.api_password}")
    log "Authorization = #{auth}" if debug_mode

    content_type = options[:content_type] || 'application/json'
    # accept       = options[:accept] || 'application/json'
    accept = content_type

    response = self.http_client.send(http_method, uri, data, {'Authorization' => "Basic #{auth}", 'Content-Type' => content_type } )

    log @debugger.join.to_s if debug_mode

    log "Response status = #{response.status}" if debug_mode


    unless response.status == 200 || response.status == 201
      if http_method == :delete && response.status == 404
        log "Warning: did not exist or was already deleted. Error = #{response.body}"
      else
        log "Unexpected result: status = #{response.status}, body = #{response.body}"
        log "DEBUGGER = #{@debugger.join.to_s}" if debug_mode
        raise StandardError.new(response.body)
      end
    end
    log response.inspect if debug_mode

    response
  end


end

