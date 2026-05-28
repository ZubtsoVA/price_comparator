Rails.application.config.after_initialize do
  service = SearchService.new
  Rails.application.config.search_service = service
  at_exit { service.close }
end