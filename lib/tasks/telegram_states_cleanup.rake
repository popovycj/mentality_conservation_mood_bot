namespace :telegram do
  task states_cleanup: :environment do
    def clear_all_user_and_handler_states
      config_path = Rails.root.join('config', 'redis', 'shared.yml')
      config = YAML.load(ERB.new(File.read(config_path)).result)[Rails.env]

      redis_client = Redis.new(url: config['url'])

      user_state_keys = redis_client.keys('user_*_state')
      handler_state_keys = redis_client.keys('*Handler_state')

      all_keys = user_state_keys + handler_state_keys
      all_keys.each { |key| redis_client.del(key) }
    end

    clear_all_user_and_handler_states
    puts 'All user and handler states cleared.'
  end
end
