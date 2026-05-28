module Parsers
  class WildberriesParser < BaseParser
    SEARCH_URL     = "https://www.wildberries.ru/catalog/0/search.aspx?search=%s&page=%d"
    CARD_SELECTOR = 'article[class*="product"]'

    def search(query, page_num = 1)
      url  = SEARCH_URL % [CGI.escape(query), page_num]
      Rails.logger.info "WB: Starting search '#{query}', page #{page_num}"

      page = open_page(url, wait_selector: CARD_SELECTOR)
      return [] if page.nil?

      scroll_until_loaded(page, CARD_SELECTOR)

      items = page.evaluate(<<~JS)
        (() => {
          const results = [];
          const seenLinks = new Set();
          const cards = document.querySelectorAll('article[class*="product"]');

          cards.forEach(card => {
            const linkEl = card.querySelector('a');
            if (!linkEl) return;

            const link = linkEl.href.split('?')[0];
            if (seenLinks.has(link)) return;

            let price = null;
            const priceEl = card.querySelector('ins.price__lower-price, .price__lower-price, .price__wrap ins');
            if (priceEl) {
              price = priceEl.innerText.replace(/[^0-9]/g, '');
            } else {
              const altPriceEl = card.querySelector('.price__wrap, .product-card__price');
              if (altPriceEl) {
                const priceText = altPriceEl.innerText.split('₽')[0] || altPriceEl.innerText;
                price = priceText.replace(/[^0-9]/g, '');
              }
            }
            if (!price) return;

            let name = "Товар WB";
            const brandEl = card.querySelector('.product-card__brand, .brand-name');
            const nameEl  = card.querySelector('.product-card__name, .goods-name');
            let brandText = brandEl ? brandEl.innerText.trim() : "";
            let nameText  = nameEl  ? nameEl.innerText.trim()  : "";
            if (nameText.startsWith("/")) nameText = nameText.substring(1).trim();
            if (brandText || nameText) name = (brandText + " " + nameText).trim();

            const imgEl = card.querySelector('img');

            let rating = "0";
            const ratingEl = card.querySelector('.address-rate-mini, .product-card__rating');
            if (ratingEl) rating = ratingEl.innerText.trim().replace(",", ".");

            let reviews = "0";
            const reviewsEl = card.querySelector('.product-card__count');
            if (reviewsEl) reviews = reviewsEl.innerText.replace(/[^0-9]/g, '');

            seenLinks.add(link);
            results.push({
              source: "wb",
              name: name,
              price: price,
              link: link,
              img: imgEl ? imgEl.src : null,
              rating: rating,
              reviews_qty: reviews
            });
          });

          return results;
        })()
      JS

      Rails.logger.info "WB: Collected #{items.length} items"
      items
    rescue => e
      Rails.logger.error "WB: Error in search: #{e.message}"
      []
    ensure
      page&.close
    end
  end
end
