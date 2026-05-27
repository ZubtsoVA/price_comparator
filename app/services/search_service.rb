class SearchService
  CACHE_TTL = 2.hours

  def initialize
    @wb_parser   = Parsers::WildberriesParser.new
    @ozon_parser = Parsers::OzonParser.new
  end

  def search(query, page_num: 1, no_cache: false)
    page_num  = [page_num.to_i, 1].max
    cache_key = "#{query.strip.downcase}_#{page_num}"

    unless no_cache
      cached = SearchCache.fetch(cache_key)
      if cached
        Rails.logger.info "Cache hit for '#{query}' page #{page_num}"
        return cached
      end
    end

    Rails.logger.info "Parsing '#{query}' page #{page_num}..."

    wb_future   = Concurrent::Future.execute { @wb_parser.search(query, page_num) }
    ozon_future = Concurrent::Future.execute { @ozon_parser.search(query, page_num) }

    wb_results   = wb_future.value || []
    ozon_results = ozon_future.value || []

    results = wb_results + ozon_results

    if results.any?
      persist_results(results)
      SearchCache.store(cache_key, results, ttl: CACHE_TTL)
    end

    results
  end

  def clear_cache
    count = SearchCache.delete_all
    { status: "success", message: "Cache cleared, #{count} items removed." }
  end

  def close
    @wb_parser.close
    @ozon_parser.close
  end

  private

  def persist_results(results)
    results.each do |item|
      platform = Platform.find_by!(slug: item["source"])

      product = Product.find_or_create_by(link: item["link"], platform: platform) do |p|
        p.name        = item["name"]
        p.image_url   = item["img"]
        p.rating      = item["rating"].to_f
        p.reviews_qty = item["reviews_qty"].to_s.gsub(/[^0-9]/, "").to_i
      end

      product.update(
        name:        item["name"],
        image_url:   item["img"],
        rating:      item["rating"].to_f,
        reviews_qty: item["reviews_qty"].to_s.gsub(/[^0-9]/, "").to_i
      )

      Price.create!(
        product:     product,
        platform:    platform,
        amount:      item["price"].to_s.gsub(/[^0-9]/, "").to_i,
        recorded_at: Time.current
      )
    end
  rescue => e
    Rails.logger.error "SearchService#persist_results error: #{e.message}"
  end
end
