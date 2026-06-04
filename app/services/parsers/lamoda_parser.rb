module Parsers
  class LamodaPlaywrightParser < BasePlaywrightParser
    SEARCH_URL    = "https://www.lamoda.ru/catalogsearch/result/?q=%s"
    CARD_SELECTOR = "div.x-product-card__link"

    def search(query, page_num = 1)
      url = SEARCH_URL % CGI.escape(query)
      Rails.logger.info "Lamoda: Starting search '#{query}', page #{page_num}"

      page = open_page_lamoda(url)
      return [] if page.nil?

      scroll_until_loaded(page, CARD_SELECTOR)

      items = page.evaluate(<<~JS)
        (() => {
          const results = [];
          const seenLinks = new Set();
          const cards = document.querySelectorAll('div.x-product-card__link');

          cards.forEach(card => {
            const linkEl = card.querySelector('a[href*="/p/"]');
            if (!linkEl) return;

            const link = linkEl.href.split('?')[0];
            if (seenLinks.has(link)) return;

            const imgEl = card.querySelector('img');
            const brandEl = card.querySelector('[class*="brand"]');
            const nameEl  = card.querySelector('[class*="name"]');

            const brand = brandEl?.textContent?.trim() || "";
            const nameRaw = nameEl?.textContent?.trim() || "";
            const name = (brand && nameRaw && nameRaw !== brand)
              ? `${brand} ${nameRaw}`.trim()
              : (card.textContent?.match(/#{brand}\\s+(.+?)(?=\\s{2,}|\\d|$)/)?.[1]?.trim() || brand || "Товар Lamoda");

            // Цена — берём первое число с ₽ из текста карточки
            const priceMatch = card.textContent?.match(/(\d[\d\s]+)\s*₽/);
            if (!priceMatch) return;
            const price = priceMatch[1].replace(/\s/g, '');

            // Рейтинг
            let rating = "0";
            const ratingMatch = card.textContent?.match(/(\d[.,]\d)/);
            if (ratingMatch) rating = ratingMatch[1].replace(",", ".");

            // Отзывы
            let reviews = "0";
            const reviewsMatch = card.textContent?.match(/\((\d+)\)/);
            if (reviewsMatch) reviews = reviewsMatch[1];

            seenLinks.add(link);
            results.push({
              source: "lamoda",
              name,
              price,
              link,
              img: imgEl ? imgEl.src : null,
              rating,
              reviews_qty: reviews
            });
          });

          return results;
        })()
      JS

      Rails.logger.info "Lamoda: Collected #{items.length} items"
      items
    rescue => e
      Rails.logger.error "Lamoda: Error in search: #{e.message}"
      []
    ensure
      page&.context&.close
    end

    private

    def open_page_lamoda(url)
      page = new_stealth_page

      begin
        page.goto(url, waitUntil: "domcontentloaded", timeout: 30_000)
      rescue Playwright::TimeoutError
        Rails.logger.warn "Lamoda: domcontentloaded timeout — continuing"
      end

      begin
        page.wait_for_selector(CARD_SELECTOR, timeout: 15_000)
      rescue Playwright::TimeoutError
        Rails.logger.error "Lamoda: Timeout waiting for products"
        page.context.close
        return nil
      end

      page
    rescue => e
      Rails.logger.error "Lamoda open_page error: #{e.message}"
      page&.context&.close
      nil
    end
  end
end