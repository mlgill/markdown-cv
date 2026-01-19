# frozen_string_literal: true

# Plugin to load data files from mlgill.github.io repository
# Loads YAML data files and copies papers.bib for jekyll-scholar

module LoadExternalData
  class Generator < Jekyll::Generator
    safe true
    priority :high

    # Path to the source website repo (relative to markdown-cv)
    SOURCE_REPO = '../mlgill.github.io'

    # Data files to load
    DATA_FILES = %w[education experience service awards patents presentations press bio socials].freeze

    def generate(site)
      source_path = File.expand_path(SOURCE_REPO, site.source)

      load_yaml_data(site, source_path)
      copy_bibliography(site, source_path)
      log_summary(site)
    end

    private

    def load_yaml_data(site, source_path)
      data_path = File.join(source_path, '_data')

      DATA_FILES.each do |name|
        file = File.join(data_path, "#{name}.yml")
        if File.exist?(file)
          site.data[name] = YAML.safe_load(File.read(file), permitted_classes: [Date, Time])
          Jekyll.logger.info "LoadExternalData:", "Loaded #{name}.yml"
        else
          Jekyll.logger.warn "LoadExternalData:", "File not found: #{file}"
        end
      end
    end

    def copy_bibliography(site, source_path)
      source_bib = File.join(source_path, '_bibliography', 'papers.bib')
      dest_bib = File.join(site.source, '_bibliography', 'papers.bib')

      if File.exist?(source_bib)
        # Create destination directory if needed
        FileUtils.mkdir_p(File.dirname(dest_bib))

        # Read and transform LaTeX math mode to HTML
        content = File.read(source_bib)
        content = convert_latex_to_html(content)

        # Write transformed content
        File.write(dest_bib, content)
        Jekyll.logger.info "LoadExternalData:", "Copied papers.bib (with LaTeX to HTML conversion)"
      else
        Jekyll.logger.warn "LoadExternalData:", "Bibliography not found: #{source_bib}"
      end
    end

    # Convert LaTeX math mode notation to HTML
    # Handles patterns like $^{13}$C, $_{3}$, $^{205}$Tl, etc.
    def convert_latex_to_html(content)
      result = content.dup

      # Handle math mode superscripts: $^{text}$ -> <sup>text</sup>
      result.gsub!(/\$\^\{([^}]*)\}\$/, '<sup>\1</sup>')
      # Handle single char superscripts: $^x$ -> <sup>x</sup>
      result.gsub!(/\$\^([^$\s{}])\$/, '<sup>\1</sup>')

      # Handle math mode subscripts: $_{text}$ -> <sub>text</sub>
      result.gsub!(/\$_\{([^}]*)\}\$/, '<sub>\1</sub>')
      # Handle single char subscripts: $_x$ -> <sub>x</sub>
      result.gsub!(/\$_([^$\s{}])\$/, '<sub>\1</sub>')

      result
    end

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
