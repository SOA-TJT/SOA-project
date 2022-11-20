# frozen_string_literal: true

# Requires all ruby files in specified app folders
# def require_app(folders = %w[infrastructure views domain controllers presentation])
def require_app(folders = %w[infrastructure models presentation domain controllers])
  app_list = Array(folders).map { |folder| "app/#{folder}" }
  full_list = ['config', app_list].flatten.join(',')
  # print full_list
  Dir.glob("./{#{full_list}}/**/*.rb").each do |file|
    require file
  end
end
# require_app
