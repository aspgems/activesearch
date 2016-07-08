require "httparty"
require "active_support/core_ext/object/json"

module ActiveSearch
  module Algolia
    class Client
      include HTTParty

      def self.configure(api_key, app_id, index = "activesearch")
        base_uri "https://#{app_id}.algolia.io/1/indexes/#{index}"
        headers({
          "X-Algolia-API-Key" => api_key,
          "X-Algolia-Application-Id" => app_id,
          "Content-Type" => "application/json; charset=utf-8"
        })
      end

      def delete_index
        self.class.delete("")
      end

      def delete(id)
        return false if id.nil?
        self.class.delete("/#{id}")
      end

      def save(id, object)
        self.class.put("/#{id}", body: object.to_json)
      end

      def query_text(text, extras = {}, options = {})
        page, per_page = options[:page] || 0, options[:per_page] || 20

        response = self.class.get('', query: extras.merge!(
          query:        text,
          page:         page,
          hitsPerPage:  per_page
        ))

        ResultsSet.new(response, page, per_page)
      end

      def get(id)
        self.class.get("/#{id}")
      end

      def find_from_resource(type, id, &block)
        query = {
          tags:   "original_type:#{type},original_id:#{id}",
          query:  ''
        }

        self.class.get('', query: query)['hits'].each(&block)
      end

    end
  end
end
