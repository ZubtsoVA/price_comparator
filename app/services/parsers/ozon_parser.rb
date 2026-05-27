module Parsers
  class OzonParser < BaseParser
    SEARCH_URL    = "https://www.ozon.ru/search/?text=%s&from_global=true&page=%d"
    CARD_SELECTOR = '[data-widget*="tile"], [class*="tile-root"], .tile-root'

    def search(query, page_num = 1)
      # Заглушка - позже замените на полный код
      Rails.logger.info "Ozon: Starting search '#{query}', page #{page_num}"
      []
    end
  end
end
