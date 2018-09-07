require 'uri'
require 'cgi'
require "purl/version"

module Purl
  class InvalidPurlError < StandardError; end

  class Generic
    def initialize(string)
      @string = string
      _string = string.gsub(/^pkg:\/*/, 'pkg://')

      begin
        @uri = URI.parse(_string)
      rescue URI::InvalidURIError
        raise InvalidPurlError.new
      end

      validates_scheme
      validates_type
      validates_name
    end

    def scheme
      @uri.scheme.try(:downcase)
    end

    def type
      @uri.host.try(:downcase)
    end

    def namespace
      *namespace, tail = @uri.path.split("/")

      namespace = namespace.join("/").
                            gsub(/^\/|\/$/, ''). # strip leading or trailing '/'
                            downcase

      namespace.empty? ? nil : URI.unescape(namespace)
    end

    def name
      *head, name_and_version = @uri.path.split("/")

      if type == 'nuget' # not in the spec, but in the tests: 'nuget names are case sensitive'
        name_and_version.split("@").first
      elsif type == 'pypi' # from spec: downcased, and '_' converted to '-'
        name_and_version.split("@").first.try(:downcase).try(:gsub, '_', '-')
      else
        name_and_version.split("@").first.try(:downcase)
      end
    end

    def version
      *head, name_and_version = @uri.path.split("/")
      name_and_version.include?("@") ? name_and_version.split("@").last.downcase : nil
    end

    def qualifiers
      @uri.query.nil? ? @uri.query : Hash[URI::decode_www_form(@uri.query.downcase)]
    end

    def subpath
      @uri.fragment.try(:gsub, /^\/|\/$/, '').try(:downcase) # strip leading or trailing '/'
    end

    def to_s(format = nil)
      if format == :canonical || format == "canonical"
        escaped_namespace = namespace.nil? ? namespace : CGI.escape(namespace)

        partial = "pkg:" + [type, escaped_namespace, name].compact.join("/")
        partial = [partial, version].compact.join("@")
        partial = [
                    partial,
                    qualifiers.nil? ? qualifiers : URI.unescape(URI.encode_www_form(qualifiers))
                  ].compact.join("?")

        [partial, subpath].compact.join("#")
      else
        @string
      end
    end

    private

      def validates_scheme
        raise InvalidPurlError.new('scheme must be pkg: or pgk://') unless scheme == "pkg"
      end

      def validates_type
        if type.nil? || type.empty?
          raise InvalidPurlError.new('type is required')
        end

        if type =~ /^\d/
          raise InvalidPurlError.new('type cannot start with a number')
        end

        if !type =~ /^[a-zA-Z0-9\.\+\-]+$/
          raise InvalidPurlError.new("type can only be composed of ASCII letters and numbers, '.', '+' and '-' (period, plus, and dash)")
        end
      end

      def validates_name
        if name.nil? || name.empty?
          raise InvalidPurlError.new('name is required')
        end
      end
  end

  class << self
    def parse(string)
      Generic.new(string)
    end
  end
end

if !defined?(ActiveSupport)
  require "purl/monkey_patches/object/try"
end
