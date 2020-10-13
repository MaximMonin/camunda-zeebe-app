module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def as_indexed_json(_options = {})
      as_json(only: %i[chat_id user_id message files created_at])
    end

    settings settings_attributes do
      mappings dynamic: false do
        indexes :chat_id, type: :long
        indexes :user_id, type: :long
        indexes :message, type: :text, analyzer: :autocomplete
        indexes :files, type: :text, analyzer: :autocomplete
        indexes :created_at, type: :date
      end
    end

    def self.search(query, chat_id)
      set_filters = lambda do |context_type, filter|
        @search_definition[:query][:bool][context_type] |= [filter]
      end

      @search_definition = {
        size: 100,
        query: {
          bool: {
            must: [],
            filter: []
          }
        }
      }

      if query.blank?
        set_filters.call(:must, match_all: {})
      else
        set_filters.call(
          :must,
          multi_match: {
            query: query,
            fields: [:message, :files]
          }
        )
      end
      if chat_id.present?
        set_filters.call(
          :filter, 
          match_phrase: {
            "chat_id": chat_id
          }
        )
      end

      __elasticsearch__.search(@search_definition)
    end
  end

  class_methods do
    def settings_attributes
      {
        index: {
          analysis: {
            analyzer: {
              autocomplete: {
                type: :custom,
                tokenizer: :standard,
                filter: %i[lowercase autocomplete]
              }
            },
            filter: {
              autocomplete: {
                type: :edge_ngram,
                min_gram: 2,
                max_gram: 20
              }
            }
          }
        }
      }
    end
  end
end