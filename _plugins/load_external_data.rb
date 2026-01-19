# frozen_string_literal: true

# Plugin to load YAML data files from mlgill.github.io repository
# This replaces the fragile markdown parser with simple YAML loading

module LoadExternalData
  class Generator < Jekyll::Generator
    safe true
    priority :high

    # Path to the source website repo (relative to markdown-cv)
    SOURCE_REPO = '../mlgill.github.io'

    # Data files to load
    DATA_FILES = %w[education experience service awards patents presentations press bio socials].freeze

    def generate(site)
      data_path = File.join(File.expand_path(SOURCE_REPO, site.source), '_data')

      DATA_FILES.each do |name|
        file = File.join(data_path, "#{name}.yml")
        if File.exist?(file)
          site.data[name] = YAML.safe_load(File.read(file), permitted_classes: [Date, Time])
          Jekyll.logger.info "LoadExternalData:", "Loaded #{name}.yml"
        else
          Jekyll.logger.warn "LoadExternalData:", "File not found: #{file}"
        end
      end

      # Log summary
      log_summary(site)
    end

    private

    def log_summary(site)
      counts = {
        'education' => site.data['education']&.size || 0,
        'experience' => site.data['experience']&.size || 0,
        'service' => site.data['service']&.size || 0,
        'awards' => site.data['awards']&.size || 0,
        'patents' => site.data['patents']&.sum { |y| y['entries']&.size || 0 } || 0,
        'presentations' => site.data['presentations']&.sum { |y| y['entries']&.size || 0 } || 0,
        'press' => site.data['press']&.size || 0
      }

      Jekyll.logger.info "LoadExternalData:", "Summary: #{counts.map { |k, v| "#{v} #{k}" }.join(', ')}"
    end
  end
end
