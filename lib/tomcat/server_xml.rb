require 'nokogiri'

class Tomcat::ServerXML

    attr_accessor :services

    ##
    # This loads the server.xml and get's it all ready
    #
    def initialize(serverxml_filename)
      @doc = Nokogiri::XML(File.open(serverxml_filename))
      @services = []

      build_services
    end

    private


      def build_services
        @doc.xpath('//Service').each do |service|
          service = Tomcat::Service.new
          name = service[:name]
          start_line = service.line
          end_line   = end_line_lookup[start_line]

          # Create an array with all connectors and the needed attributes in a hash
          connectors = []
          service.children.css('Connector').each do |connector|
            connectors << {:ip => connector[:address], :port => connector[:port]}
          end

          # Create an array with all docBases
          docBase = []
          service.children.css('Context').each do |context|
            docBase << context[:docBase]
          end

          resources = []
          service.children.css('Resource').each do |resource|
            db_host     = resource[:url].scan(%r{mysql://(.*)/}).join.sub(/^127\.0\.0\.1$/, "localhost") if String === resource[:url]
            schema_name = resource[:url].scan(%r{/([^/]+)\?}).join if String === resource[:url]

            if resources.empty?
              resources << {:db_host => db_host, :schema_name => schema_name}
            else
              duplicate=""
              resources.each do |i|
                if i[:db_host] == db_host and i[:schema_name] == schema_name
                  duplicate=true
                end
              end
              if duplicate != true
                resources << {:db_host => db_host, :schema_name => schema_name}
              end
            end
          end

          if options[:old]
            # Create schemas array for all schema names, then add NAMEuser schema.
            schemas = resources.inject([]) do |result, resource|
              result << resource[:schema_name]
              result
            end
            schemas.delete_if { |x| x == nil }
            ## This is for SpigitEngage:
            schemas << "#{schemas[0]}user" if schemas.count > 0

            # Create dbhost variable and check some stuff out
            db_hosts = resources.inject([]) do |result, resource|
              result << resource[:db_host]
              result
            end.uniq
            if db_hosts.count > 1
              puts "WARNING: We found miltiple hosts for the schema's, exiting..."
              p db_hosts if options[:debug]
              exit 1
            end

            # Create ips array for all ip addresses
            ips = connectors.inject([]) do |result, connector|
              result << connector[:ip]
              result
            end
            puts "#{start_line},#{end_line}:#{ips.uniq.join(',')}:#{docBase.uniq.join(',')}:#{db_hosts.join(',')}:#{schemas.join(',')}:#{name}" unless output_filename
            open(output_filename, 'a') { |f|
              f.puts "#{start_line},#{end_line}:#{ips.uniq.join(',')}:#{docBase.uniq.join(',')}:#{db_hosts.join(',')}:#{schemas.join(',')}:#{name}"
            } if output_filename
          else
            serviceDefintion = {:start_line => start_line, :end_line => end_line, :name => name, :connectors => connectors.uniq, :docBases => docBase.uniq, :resources => resources}
            p serviceDefintion unless output_filename
          end
        end
      end



end
