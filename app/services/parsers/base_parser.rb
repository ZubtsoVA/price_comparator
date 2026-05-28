module Parsers
  class BaseParser
    SCROLL_TARGET    = 42
    SCROLL_MAX_LOOPS = 15
    SCROLL_STEP_PX   = 1000
    SCROLL_PAUSE_MS  = 450
    PAGE_TIMEOUT_MS  = 30_000

    def initialize
      @browser = Ferrum::Browser.new(
        headless: true,
        timeout: 30,
        browser_options: {
          "no-sandbox": nil,
          "disable-dev-shm-usage": nil,
          "disable-gpu": nil,
          "window-size": "1920,1080",
          "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
        }
      )
    end

    def close
      @browser&.quit
    end

    private

    def open_page(url, wait_selector:)
      page = @browser.create_page

      # Патчим webdriver ДО навигации через CDP команду страницы
      page.command("Page.addScriptToEvaluateOnNewDocument",
                   source: "Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

      page.go_to(url)
      page.network.wait_for_idle(timeout: PAGE_TIMEOUT_MS / 1000)

      deadline = Time.current + 15.seconds
      loop do
        break if page.css(wait_selector).any?
        raise "Timeout waiting for #{wait_selector}" if Time.current > deadline
        sleep 0.3
      end

      page
    rescue => e
      Rails.logger.error "BaseParser#open_page error: #{e.message}"
      page&.close
      nil
    end

    def scroll_until_loaded(page, card_selector)
      SCROLL_MAX_LOOPS.times do |i|
        count = page.evaluate("document.querySelectorAll('#{card_selector}').length")
        Rails.logger.info "Scroll step #{i + 1}: #{count} cards found"
        break if count >= SCROLL_TARGET

        page.execute("window.scrollBy(0, #{SCROLL_STEP_PX})")
        sleep(SCROLL_PAUSE_MS / 1000.0)
      end
      sleep 0.5
    end
  end
end
