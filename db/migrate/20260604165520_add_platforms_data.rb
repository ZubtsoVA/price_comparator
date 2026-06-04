class AddPlatformsData < ActiveRecord::Migration[8.1]
  def change
    Platform.find_or_create_by(slug: 'wb') do |p|
      p.name = 'Wildberries'
      p.base_url = 'https://www.wildberries.ru'
    end

    Platform.find_or_create_by(slug: 'lamoda') do |p|
      p.name = 'Lamoda'
      p.base_url = 'https://www.lamoda.ru'
    end
  end
end
