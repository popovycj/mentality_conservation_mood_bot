namespace :cleanup do
  desc "Remove duplicate albums"
  task remove_duplicate_albums: :environment do
    puts "Starting the process to remove duplicate albums..."

    duplicates = Album.group(:name).having('COUNT(*) > 1').count
    duplicates.each do |name, count|
      album_ids_to_delete = Album.where(name: name).order(:created_at).pluck(:id).drop(1)

      Album.where(id: album_ids_to_delete).destroy_all

      puts "Removed #{count - 1} duplicates for album '#{name}'"
    end

    puts "Duplicate removal process completed."
  end
end
