namespace :logs do
  desc "tail rails logs" 
  task :tail_rails do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end

namespace :setup do
  desc "Create the database."
  task :create_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:create"
        end
      end
    end
  end
end

namespace :setup do
  desc "baidu article"
  task :baidu_article do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "baidu_article:puts"
        end
      end
    end
  end
end

namespace :load do
  task :defaults do
    load 'capistrano/defaults.rb'
  end
end

stages.each do |stage|
  Rake::Task.define_task(stage) do
    set(:stage, stage.to_sym)

    invoke 'load:defaults'
    load deploy_config_path
    load stage_config_path.join("#{stage}.rb")
    load "capistrano/#{fetch(:scm)}.rb"
    I18n.locale = fetch(:locale, :en)
    configure_backend
  end
end
Rake::Task[:production].invoke
